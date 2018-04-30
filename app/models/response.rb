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

  def display_as_html(prefix = nil, count = nil, _file_url = nil, show_tags = nil, current_user = nil)
    identifier = ""
    # The following three lines print out the type of rubric before displaying
    # feedback.  Currently this is only done if the rubric is Author Feedback.
    # It doesn't seem necessary to print out the rubric type in the case of
    # a ReviewResponseMap.
    identifier += "<h3>Feedback from author</h3>" if self.map.type.to_s == 'FeedbackResponseMap'
    if prefix # has prefix means view_score page in instructor end
      self_id = prefix + '_' + self.id.to_s
      code = construct_instructor_html identifier, self_id, count
    else # in student end
      self_id = self.id.to_s
      code = construct_student_html identifier, self_id, count
    end
    code = construct_review_response code, self_id, show_tags, current_user
    code.html_safe
  end

  # Computes the total score awarded for a review
  def total_score
    # only count the scorable questions, only when the answer is not nil
    # we accept nil as answer for scorable questions, and they will not be counted towards the total score
    sum = 0
    scores.each do |s|
      question = Question.find(s.question_id)
      sum += s.answer * question.weight if !s.answer.nil? && question.is_a?(ScoredQuestion)
    end
    sum
  end

  def delete
    self.scores.each(&:destroy)
    self.destroy
  end

  # bug fixed
  # Returns the average score for this response as an integer (0-100)
  def average_score
    if maximum_score != 0
      ((total_score.to_f / maximum_score.to_f) * 100).round
    else
      "N/A"
    end
  end

  # Returns the maximum possible score for this response
  def maximum_score
    # only count the scorable questions, only when the answer is not nil (we accept nil as answer for scorable questions, and they will not be counted towards the total score)
    total_weight = 0
    scores.each do |s|
      question = Question.find(s.question_id)
      total_weight += question.weight if !s.answer.nil? && question.is_a?(ScoredQuestion)
    end
    questionnaire = if scores.empty?
                      questionnaire_by_answer(nil)
                    else
                      questionnaire_by_answer(scores.first)
                    end
    total_weight * questionnaire.max_question_score
  end

  # only two types of responses more should be added
  def email(partial = "new_submission")
    defn = {}
    defn[:body] = {}
    defn[:body][:partial_name] = partial
    response_map = ResponseMap.find map_id
    participant = Participant.find(response_map.reviewer_id)
    # parent is used as a common variable name for either an assignment or course depending on what the questionnaire is associated with
    parent = if response_map.survey?
               response_map.survey_parent
             else
               Assignment.find(participant.parent_id)
             end
    defn[:subject] = "A new submission is available for " + parent.name
    response_map.email(defn, participant, parent)
  end

  def questionnaire_by_answer(answer)
    if !answer.nil? # for all the cases except the case that  file submission is the only question in the rubric.
      questionnaire = Question.find(answer.question_id).questionnaire
    else
      # there is small possibility that the answers is empty: when the questionnaire only have 1 question and it is a upload file question
      # the reason is that for this question type, there is no answer record, and this question is handled by a different form
      map = ResponseMap.find(self.map_id)
      assignment = Participant.find(map.reviewer_id).assignment
      questionnaire = Questionnaire.find(assignment.review_questionnaire_id)
    end
    questionnaire
  end

  def self.concatenate_all_review_comments(assignment_id, reviewer_id)
    comments = ''
    counter = 0
    @comments_in_round1 = @comments_in_round2 = @comments_in_round3 = ''
    @counter_in_round1 = @counter_in_round2 = @counter_in_round3 = 0
    assignment = Assignment.find(assignment_id)
    question_ids = Question.get_all_questions_with_comments_available(assignment_id)

    ReviewResponseMap.where(reviewed_object_id: assignment_id, reviewer_id: reviewer_id).find_each do |response_map|
      (1..assignment.num_review_rounds).each do |round|
        last_response_in_current_round = response_map.response.select {|r| r.round == round }.last
        next if last_response_in_current_round.nil?
        last_response_in_current_round.scores.each do |answer|
          comments += answer.comments if question_ids.include? answer.question_id
          instance_variable_set('@comments_in_round' + round.to_s, instance_variable_get('@comments_in_round' + round.to_s) + answer.comments ||= '')
        end
        additional_comment = last_response_in_current_round.additional_comment
        comments += additional_comment
        counter += 1
        instance_variable_set('@comments_in_round' + round.to_s, instance_variable_get('@comments_in_round' + round.to_s) + additional_comment)
        instance_variable_set('@counter_in_round' + round.to_s, instance_variable_get('@counter_in_round' + round.to_s) + 1)
      end
    end
    [comments, counter,
     @comments_in_round1, @counter_in_round1,
     @comments_in_round2, @counter_in_round2,
     @comments_in_round3, @counter_in_round3]
  end

  def self.get_volume_of_review_comments(assignment_id, reviewer_id)
    comments, counter,
        @comments_in_round1, @counter_in_round1,
        @comments_in_round2, @counter_in_round2,
        @comments_in_round3, @counter_in_round3 = Response.concatenate_all_review_comments(assignment_id, reviewer_id)

    overall_avg_vol = (Lingua::EN::Readability.new(comments).num_words / (counter.zero? ? 1 : counter)).round(0)
    review_comments_volume = []
    review_comments_volume.push(overall_avg_vol)
    (1..3).each do |i|
      avg_vol_in_round = (Lingua::EN::Readability.new(instance_variable_get('@comments_in_round' + i.to_s)).num_words / (instance_variable_get('@counter_in_round' + i.to_s).zero? ? 1 : instance_variable_get('@counter_in_round' + i.to_s))).round(0)
      review_comments_volume.push(avg_vol_in_round)
    end
    review_comments_volume
  end

  # compare the current response score with other scores on the same artifact, and test if the difference
  # is significant enough to notify instructor.
  # Precondition: the response object is associated with a ReviewResponseMap
  ### "map_class.get_assessments_for" method need to be refactored
  def significant_difference?
    map_class = self.map.class
    existing_responses = map_class.get_assessments_for(self.map.reviewee)
    average_score_on_same_artifact_from_others, count = Response.avg_scores_and_count_for_prev_reviews(existing_responses, self)
    # if this response is the first on this artifact, there's no grade conflict
    return false if count == 0
    # This score has already skipped the unfilled scorable question(s)
    score = total_score.to_f / maximum_score
    questionnaire = questionnaire_by_answer(self.scores.first)
    assignment = self.map.assignment
    assignment_questionnaire = AssignmentQuestionnaire.find_by(assignment_id: assignment.id, questionnaire_id: questionnaire.id)
    # notification_limit can be specified on 'Rubrics' tab on assignment edit page.
    allowed_difference_percentage = assignment_questionnaire.notification_limit.to_f
    # the range of average_score_on_same_artifact_from_others and score is [0,1]
    # the range of allowed_difference_percentage is [0, 100]
    (average_score_on_same_artifact_from_others - score).abs * 100 > allowed_difference_percentage
  end

  def self.avg_scores_and_count_for_prev_reviews(existing_responses, current_response)
    scores_assigned = []
    count = 0
    existing_responses.each do |existing_response|
      if existing_response.id != current_response.id # the current_response is also in existing_responses array
        count += 1
        scores_assigned << existing_response.total_score.to_f / existing_response.maximum_score
      end
    end
    [scores_assigned.sum / scores_assigned.size.to_f, count]
  end

  def notify_instructor_on_difference
    response_map = self.map
    reviewer_participant_id = response_map.reviewer_id
    reviewer_participant = AssignmentParticipant.find(reviewer_participant_id)
    reviewer_name = User.find(reviewer_participant.user_id).fullname
    reviewee_team = AssignmentTeam.find(response_map.reviewee_id)
    reviewee_participant = reviewee_team.participants.first # for team assignment, use the first member's name.
    reviewee_name = User.find(reviewee_participant.user_id).fullname
    assignment = Assignment.find(reviewer_participant.parent_id)
    Mailer.notify_grade_conflict_message(
      to: assignment.instructor.email,
      subject: 'Expertiza Notification: A review score is outside the acceptable range',
      body: {
        reviewer_name: reviewer_name,
        type: 'review',
        reviewee_name: reviewee_name,
        new_score: total_score.to_f / maximum_score,
        assignment: assignment,
        conflicting_response_url: 'https://expertiza.ncsu.edu/response/view?id=' + response_id.to_s,
        summary_url: 'https://expertiza.ncsu.edu/grades/view_team?id=' + reviewee_participant.id.to_s,
        assignment_edit_url: 'https://expertiza.ncsu.edu/assignments/' + assignment.id.to_s + '/edit'
      }
    ).deliver_now
  end

  private

  def construct_instructor_html identifier, self_id, count
    identifier += '<h4><B>Review ' + count.to_s + '</B></h4>'
    identifier += '<B>Reviewer: </B>' + self.map.reviewer.fullname + ' (' + self.map.reviewer.name + ')'
    identifier + '&nbsp;&nbsp;&nbsp;<a href="#" name= "review_' + self_id + 'Link" onClick="toggleElement(' \
           "'review_" + self_id + "','review'" + ');return false;">show review</a><BR/>'
  end

  def construct_student_html identifier, self_id, count
    identifier += '<table width="100%">'\
						 '<tr>'\
						 '<td align="left" width="70%"><b>Review ' + count.to_s + '</b>&nbsp;&nbsp;&nbsp;'\
						 '<a href="#" name= "review_' + self_id + 'Link" onClick="toggleElement(' + "'review_" + self_id + "','review'" + ');return false;">show review</a>'\
						 '</td>'\
						 '<td align="left"><b>Last Reviewed:</b>'\
						 "<span>#{(self.updated_at.nil? ? 'Not available' : self.updated_at.strftime('%A %B %d %Y, %I:%M%p'))}</span></td>"\
						 '</tr></table>'
  end

  def construct_review_response code, self_id, show_tags = nil, current_user = nil
    code += '<table id="review_' + self_id + '" style="display: none;" class="table table-bordered">'
    answers = Answer.where(response_id: self.response_id)
    unless answers.empty?
      questionnaire = self.questionnaire_by_answer(answers.first)
      questionnaire_max = questionnaire.max_question_score
      questions = questionnaire.questions.sort_by(&:seq)
      # get the tag settings this questionnaire
      tag_prompt_deployments = show_tags ? TagPromptDeployment.where(questionnaire_id: questionnaire.id, assignment_id: self.map.assignment.id) : nil
      code = add_table_rows questionnaire_max, questions, answers, code, tag_prompt_deployments, current_user
    end
    comment = if !self.additional_comment.nil?
                self.additional_comment.gsub('^p', '').gsub(/\n/, '<BR/>')
              else
                ''
              end
    code += '<tr><td><b>Additional Comment: </b>' + comment + '</td></tr>'
    code += '</table>'
  end

  def add_table_rows questionnaire_max, questions, answers, code, tag_prompt_deployments = nil, current_user = nil
    count = 0
    # loop through questions so the the questions are displayed in order based on seq (sequence number)
    questions.each do |question|
      count += 1 if !question.is_a? QuestionnaireHeader and question.break_before == true
      answer = answers.find {|a| a.question_id == question.id }
      row_class = count.even? ? "info" : "warning"
      row_class = "" if question.is_a? QuestionnaireHeader
      code += '<tr class="' + row_class + '"><td>'
      if !answer.nil? or question.is_a? QuestionnaireHeader
        code += if question.instance_of? Criterion
                  #Answer Tags are enabled only for Criterion questions at the moment.
                  question.view_completed_question(count, answer, questionnaire_max, tag_prompt_deployments, current_user)
                elsif question.instance_of? Scale
                  question.view_completed_question(count, answer, questionnaire_max)
                else
                  question.view_completed_question(count, answer)
                end
      end
      code += '</td></tr>'
    end
    code
  end
end
