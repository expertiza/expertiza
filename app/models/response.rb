require 'analytic/response_analytic'
require 'lingua/en/readability'

class Response < ActiveRecord::Base
  include ResponseAnalytic
  
  belongs_to :response_map, class_name: 'ResponseMap', foreign_key: 'map_id'
  has_many :scores, class_name: 'Answer', foreign_key: 'response_id', dependent: :destroy
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
    # a ReviewResponseMap.  Also, I'm not sure if that would have to be
    # TeamResponseMap for a team assignment.  Someone who understands the
    # situation better could add to the code later.
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

  # Function which considers a given assignment
  # and checks if a given review is still valid for score calculation
  # The basic rule is that
  # "A review is INVALID if there was new submission for the assignment
  #  before the most recent review deadline AND THE review happened before that
  #  submission"
  # response - the response whose validity is being checked
  # resubmission_times - submission times of the assignment is descending order
  # latest_review_phase_start_time
  # The function returns true if a review is valid for score calculation
  # and false otherwise
  def is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
    is_valid = true

    # if there was not submission then the response is valid
    if resubmission_times.nil? || latest_review_phase_start_time.nil?
      return is_valid
    end

    resubmission_times.each do |resubmission_time|
      # if the response is after a resubmission that is
      # before the latest_review_phase_start_time (check second condition below)
      # then we are good - the response is valid and we can break
      break if self.updated_at > resubmission_time.resubmitted_at

      # this means there was a re-submission before the
      # latest_review_phase_start_time and we dont have a response after that
      # so the response is invalid
      if resubmission_time.resubmitted_at < latest_review_phase_start_time
        is_valid = false
        break
      end
    end

    is_valid
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

    if response_map.type == "ReviewResponseMap"

    end

    defn[:subject] = "A new submission is available for " + assignment.name
    if response_map.type == "ReviewResponseMap"
      defn[:body][:type] = "Author Feedback"
      AssignmentTeam.find(response_map.reviewee_id).users.each do |user|
        defn[:body][:obj_name] = if assignment.has_topics?
                                   SignUpTopic.find(SignedUpTeam.topic_id(assignment.id, user.id)).topic_name
                                 else
                                   assignment.name
                                 end
        defn[:body][:first_name] = User.find(user.id).fullname
        defn[:to] = User.find(user.id).email
        Mailer.sync_message(defn).deliver_now
      end
    end
    if response_map.type == "MetareviewResponseMap"
      defn[:body][:type] = "Metareview"
      reviewee_user = Participant.find(response_map.reviewee_id)
      signup_topic_id = SignedUpTeam.topic_id(assignment.id, response_map.contributor.teams_users.first.user_id)

      defn[:body][:obj_name] = SignUpTopic.find(signup_topic_id).topic_name
      defn[:body][:first_name] = User.find(reviewee_user.user_id).fullname
      defn[:to] = User.find(reviewee_user.user_id).email
      Mailer.sync_message(defn).deliver
    end
    if response_map.type == "FeedbackResponseMap" # This is authors' feedback from UI
      defn[:body][:type] = "Review Feedback"
      # reviewee is a response, reviewer is a participant
      # we need to track back to find the original reviewer on whose work the author comments
      response_id_for_original_feedback = response_map.reviewed_object_id
      response_for_original_feedback = Response.find response_id_for_original_feedback
      response_map_for_original_feedback = ResponseMap.find response_for_original_feedback.map_id
      original_reviewer_participant_id = response_map_for_original_feedback.reviewer_id

      participant = AssignmentParticipant.find(original_reviewer_participant_id)
      topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
      defn[:body][:obj_name] = if topic_id.nil?
                                 assignment.name
                               else
                                 SignUpTopic.find(topic_id).topic_name
                               end

      user = User.find(participant.user_id)

      defn[:to] = user.email
      defn[:body][:first_name] = user.fullname
      Mailer.sync_message(defn).deliver
    end
    if response_map.type == "TeammateReviewResponseMap"
      defn[:body][:type] = "Teammate Review"
      participant = AssignmentParticipant.find(response_map.reviewee_id)
      topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
      defn[:body][:obj_name] = SignUpTopic.find(topic_id).topic_name rescue nil
      user = User.find(participant.user_id)
      defn[:body][:first_name] = user.fullname
      defn[:to] = user.email
      Mailer.sync_message(defn).deliver
    end
  end

  def questionnaire_by_answer(answer)
    if !answer.nil? # for all the cases except the case that  file submission is the only question in the rubric.
      questionnaire = Question.find(answer.question_id).questionnaire
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
end
