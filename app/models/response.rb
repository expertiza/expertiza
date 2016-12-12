require 'analytic/response_analytic'
require 'lingua/en/readability'

class Response < ActiveRecord::Base
  include ResponseAnalytic
  
  belongs_to :response_map, class_name: 'ResponseMap', foreign_key: 'map_id'
  has_many :scores, class_name: 'Answer', foreign_key: 'response_id', dependent: :destroy
  # TODO: change metareview_response_map relationship to belongs_to
  has_many :metareview_response_maps, class_name: 'MetareviewResponseMap', foreign_key: 'reviewed_object_id', dependent: :destroy

  alias map response_map

  attr_accessor :difficulty_rating

  delegate :questionnaire, :reviewee, :reviewer, to: :map

  def response_id
    id
  end

  def team_has_user?(user)
    reviewer.team.has_user user
  end

  def display_as_html(prefix = nil, count = nil, _file_url = nil)
    identifier = ""
    # The following three lines print out the type of rubric before displaying
    # feedback.  Currently this is only done if the rubric is Author Feedback.
    # It doesn't seem necessary to print out the rubric type in the case of
    # a ReviewResponseMap. 
    if self.map.type.to_s == 'FeedbackResponseMap'
      identifier += "<h3>Feedback from author</h3>"
    end
    if prefix # has prefix means view_score page in instructor end
      identifier += '<h4><B>Review ' + count.to_s + '</B></h4>'
      identifier += "<B>Reviewer: </B>" + self.map.reviewer.fullname + ' (' + self.map.reviewer.name + ')'
      str = prefix + "_" + self.id.to_s
    else # in student end
      identifier += '<B>Review ' + count.to_s + '</B>'
      str = self.id.to_s
    end
    code = identifier + '&nbsp;&nbsp;&nbsp;<a href="#" name= "review_' + str + 'Link" onClick="toggleElement(' + "'review_" + str + "','review'" + ');return false;">show review</a><BR/>'
    code += "<B>Last reviewed: </B> "
    code += if self.updated_at.nil?
              "Not available"
            else
              self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
            end
    code += '<table id="review_' + str + '" style="display: none;" class="table table-bordered">'
    count = 0
    answers = Answer.where(response_id: self.response_id)

    unless answers.empty?
      questionnaire = self.questionnaire_by_answer(answers.first)

      questionnaire_max = questionnaire.max_question_score
      questions = questionnaire.questions.sort {|a, b| a.seq <=> b.seq }
      # loop through questions so the the questions are displayed in order based on seq (sequence number)
      questions.each do |question|
        count += 1 if !question.is_a? QuestionnaireHeader and question.break_before == true
        answer = answers.find {|a| a.question_id == question.id }
        row_class = count.even? ? "info" : "warning"
        row_class = "" if question.is_a? QuestionnaireHeader

        code += '<tr class="' + row_class + '"><td>'
        if !answer.nil? or question.is_a? QuestionnaireHeader
          code += if question.instance_of? Criterion or question.instance_of? Scale
                    question.view_completed_question(count, answer, questionnaire_max)
                  else
                    question.view_completed_question(count, answer)
                  end
        end
        code += '</td></tr>'
      end

      comment = if !self.additional_comment.nil?
                  self.additional_comment.gsub('^p', '').gsub(/\n/, '<BR/>')
                else
                  ''
                end
      code += "<tr><td><B>Additional Comment: </B>" + comment + '</td></tr>'
    end
    code += "</table>"
    code.html_safe
  end

  # Computes the total score awarded for a review
  def get_total_score
    # only count the scorable questions, only when the answer is not nil (we accept nil as answer for scorable questions, and they will not be counted towards the total score)
    sum = 0
    scores.each do |s|
      question = Question.find(s.question_id)
      if !s.answer.nil? && question.is_a?(ScoredQuestion)
        sum += s.answer * question.weight
      end
    end
    sum
  end

  def delete
    self.scores.each(&:destroy)
    self.destroy
  end

  # bug fixed
  # Returns the average score for this response as an integer (0-100)
  def get_average_score
    if get_maximum_score != 0
      ((get_total_score.to_f / get_maximum_score.to_f) * 100).round
    else
      "N/A"
    end
  end

  # Returns the maximum possible score for this response
  def get_maximum_score
    # only count the scorable questions, only when the answer is not nil (we accept nil as answer for scorable questions, and they will not be counted towards the total score)
    total_weight = 0
    scores.each do |s|
      question = Question.find(s.question_id)
      if !s.answer.nil? && question.is_a?(ScoredQuestion)
        total_weight += question.weight
      end
    end
    questionnaire = if scores.empty?
                      questionnaire_by_answer(nil)
                    else
                      questionnaire_by_answer(scores.first)
                    end
    total_weight * questionnaire.max_question_score
  end

  # Returns the total score from this response
  def get_alternative_total_score
    # TODO: The method get_total_score() above does not seem correct.  Replace with this method.
    total_score = 0

    self.scores.each {|score| total_score += score.score }

    total_score
  end

  # only two types of responses more should be added
  def email(partial = "new_submission")
    defn = {}
    defn[:body] = {}
    defn[:body][:partial_name] = partial
    response_map = ResponseMap.find map_id
    assignment = nil

    reviewer_participant_id = response_map.reviewer_id
    participant = Participant.find(reviewer_participant_id)
    assignment = Assignment.find(participant.parent_id)

    defn[:subject] = "A new submission is available for " + assignment.name

    response_map.email(defn,participant,assignment)

  end

  def questionnaire_by_answer(answer)
    if !answer.nil? # for all the cases except the case that  file submission is the only question in the rubric.
      questionnaire = Question.find(answer.question_id).questionnaire
      # I don't think this else is necessary. Checking the callers, it seems that answer cannot be nil should be a
      # pre-condition of this method --Yang
    else
      # there is small possibility that the answers is empty: when the questionnaire only have 1 question and it is a upload file question
      # the reason is that for this question type, there is no answer record, and this question is handled by a different form
      map = ResponseMap.find(self.map_id)
      reviewer_participant = Participant.find(map.reviewer_id)
      assignment = Assignment.find(reviewer_participant.parent_id)
      questionnaire = Questionnaire.find(assignment.review_questionnaire_id)
    end
    questionnaire
  end
  
  def self.concatenate_all_review_comments(assignment_id, reviewer_id)
    comments = ''
    counter = 0
    @comments_in_round_1, @comments_in_round_2, @comments_in_round_3 = '', '', ''
    @counter_in_round_1, @counter_in_round_2, @counter_in_round_3 = 0, 0, 0
    assignment = Assignment.find(assignment_id)
    question_ids = Question.get_all_questions_with_comments_available(assignment_id)
    
    ReviewResponseMap.where(reviewed_object_id: assignment_id, reviewer_id: reviewer_id).each do |response_map|
      (1..assignment.num_review_rounds).each do |round|
        last_response_in_current_round = response_map.response.select{|r| r.round == round }.last
        unless last_response_in_current_round.nil?
          last_response_in_current_round.scores.each do |answer| 
            comments += answer.comments if question_ids.include? answer.question_id
            instance_variable_set('@comments_in_round_' + round.to_s, instance_variable_get('@comments_in_round_' + round.to_s) + answer.comments ||= '')
          end
          additional_comment = last_response_in_current_round.additional_comment
          comments += additional_comment
          counter += 1
          instance_variable_set('@comments_in_round_' + round.to_s, instance_variable_get('@comments_in_round_' + round.to_s) + additional_comment)
          instance_variable_set('@counter_in_round_' + round.to_s, instance_variable_get('@counter_in_round_' + round.to_s) + 1)
        end
      end
    end
    [comments, counter,
     @comments_in_round_1, @counter_in_round_1,
     @comments_in_round_2, @counter_in_round_2,
     @comments_in_round_3, @counter_in_round_3]
  end

  def self.get_volume_of_review_comments(assignment_id, reviewer_id)
    comments, counter,
    comments_in_round_1, counter_in_round_1,
    comments_in_round_2, counter_in_round_2,
    comments_in_round_3, counter_in_round_3 = Response.concatenate_all_review_comments(assignment_id, reviewer_id)

    overall_avg_vol = (Lingua::EN::Readability.new(comments).num_words / (counter.zero? ? 1 : counter)).round(0)
    avg_vol_in_round_1 = (Lingua::EN::Readability.new(comments_in_round_1).num_words / (counter_in_round_1.zero? ? 1 : counter_in_round_1)).round(0)
    avg_vol_in_round_2 = (Lingua::EN::Readability.new(comments_in_round_2).num_words / (counter_in_round_2.zero? ? 1 : counter_in_round_2)).round(0)
    avg_vol_in_round_3 = (Lingua::EN::Readability.new(comments_in_round_3).num_words / (counter_in_round_3.zero? ? 1 : counter_in_round_3)).round(0)
    [overall_avg_vol, avg_vol_in_round_1, avg_vol_in_round_2, avg_vol_in_round_3]
  end
  def notify_on_difference(new_pct, avg_pct, limit,response_id)
    mapping = self.map
    instructor = mapping.assignment.instructor
    team_id = mapping.reviewee_id
    teams_users = TeamsUser.where(team_id: team_id)
    user_id=nil
    teams_users.each do |team_user|
      user_id=team_user.user_id;
    end
    current_user = User.find_by(id: user_id)
    @student_tasks = StudentTask.from_user current_user
    @student_tasks.each do |student_task|
      if student_task.assignment.id == mapping.assignment.id
        team_id = student_task.participant.id
      end
    end
    Mailer.generic_message(
        {:to => instructor.email,
         :subject => "Expertiza Notification: A review score is outside the acceptable range",
         :body => {
             :first_name => ApplicationHelper::get_user_first_name(instructor),
             :reviewer_name => mapping.reviewer.fullname,
             :type => "review",
             :reviewee_name => mapping.reviewee.fullname,
             :limit => limit,
             :new_pct => new_pct,
             :avg_pct => avg_pct,
             :types => "reviews",
             :performer => "reviewer",
             :assignment => mapping.assignment,
             :partial_name => 'limit_notify',
             :conflicting_response_url => '0.0.0.0:3000/response/view?id='+response_id.to_s,  #'https://expertiza.ncsu.edu/response/view?id='
             :summary_url => '0.0.0.0:3000/grades/view_team?id='+team_id.to_s #mapping.reviewee_id.to_s
         }
        }
    ).deliver_now
  end
  def self.compare_scores(new_response, questionnaire)
    map_class = new_response.map.class
    existing_responses = map_class.get_assessments_for(new_response.map.reviewee)
    total, count = get_total_scores_for_prev_reviews(existing_responses, new_response)
    if count > 0
      notify_instructor(new_response.map.assignment, new_response, questionnaire, total, count)
    end

  end
  def self.get_total_scores_for_prev_reviews(item_list, curr_item)
    total = 0
    count = 0
    item_list.each {
        |item|
      if item.id != curr_item.id
        count += 1
        total += item.get_total_score
      end
    }
    return total, count
  end

  def self.notify_instructor(assignment, curr_item, questionnaire, total, count)
    max_possible_score = curr_item.get_maximum_score
    new_score = curr_item.get_total_score;
    existing_score = (total.to_f/count).to_f

    aq = AssignmentQuestionnaire.where(user_id: assignment.instructor_id, assignment_id: assignment.id, questionnaire_id: questionnaire.id).first

    unless aq
      aq = AssignmentQuestionnaire.where(user_id: assignment.instructor_id, assignment_id: nil, questionnaire_id: nil).first
    end

    if aq
      allowed_difference = max_possible_score.to_f * aq.notification_limit / 100
      if new_score < (existing_score - allowed_difference) or new_score > (existing_score + allowed_difference)
        new_pct = new_score.to_f/max_possible_score
        avg_pct = existing_score.to_f/max_possible_score
        curr_item.notify_on_difference(new_pct, avg_pct, aq.notification_limit,curr_item.id)
      end
    end
  end
end
