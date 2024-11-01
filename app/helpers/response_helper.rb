module ResponseHelper
  # E2218: this module contains methods that are used in response_controller class

  # locks a response based on an authenticated user
  def lock_response(map,curr_response)
    if map_team_reviewing_enabled?(map.team_reviewing_enabled)
      this_response = Lock.get_lock(curr_response, current_user, Lock::DEFAULT_TIMEOUT)
      if this_response.nil?
        response_lock_action
      end
      return this_response
    end
    return curr_response
  end

  # This method is called within set_action_parameters and when the header='New'
  # Depending on what type of response map corresponds to this response, the method gets the reference to the proper questionnaire
  # This is called after assign_instance_vars in the new method
  def questionnaire_from_response_map(map,contributor,assignment)
    case map.type
    when 'ReviewResponseMap', 'SelfReviewResponseMap'
      reviewees_topic = SignedUpTeam.topic_id_by_team_id(contributor.id)
      current_round = assignment.number_of_current_round(reviewees_topic)
      current_questionnaire = map.questionnaire(current_round, reviewees_topic)
    when
      'MetareviewResponseMap',
      'TeammateReviewResponseMap',
      'FeedbackResponseMap',
      'CourseSurveyResponseMap',
      'AssignmentSurveyResponseMap',
      'GlobalSurveyResponseMap',
      'BookmarkRatingResponseMap'
      if assignment.duty_based_assignment?
        # E2147 : gets questionnaire of a particular duty in that assignment rather than generic questionnaire
        current_questionnaire = map.questionnaire_by_duty(map.reviewee.duty_id)
      else
        current_questionnaire = map.questionnaire
      end
    end
    return current_questionnaire
  end

  # This method is called within set_content when the new_response flag is set to False
  # This method gets the questionnaire directly from the response object since it is available.
  def questionnaire_from_response(response)
    # if user is not filling a new rubric, the @response object should be available.
    # we can find the questionnaire from the question_id in answers
    answer = response.scores.first
    current_questionnaire = response.questionnaire_by_answer(answer)

    return current_questionnaire
  end

  # checks if the questionnaire is nil and opens drop down or rating accordingly
  def get_dropdown_or_scale(assignment,questionnaire)
    use_dropdown = AssignmentQuestionnaire.where(assignment_id: assignment.try(:id),
                                                 questionnaire_id: questionnaire.try(:id))
                                          .first.try(:dropdown)
    dropdown_or_scale = (use_dropdown ? 'dropdown' : 'scale')

    return dropdown_or_scale
  end

  #this method gets the current_round parameter given an assignment and returns it to the caller
  #this is used to set the @current_round parameter inside the controller"
  def get_current_round(assignment)
    current_round = assignment.number_of_current_round(reviewees_topic)
  end

  # E-1973 - helper method to check if the current user is the reviewer
  # if the reviewer is an assignment team, we have to check if the current user is on the team
  def current_user_is_reviewer?(map, _reviewer_id)
    map.reviewer.current_user_is_reviewer? current_user.try(:id)
  end

  # sorts the questions passed by sequence number in ascending order
  def sort_items(items)
    items.sort_by(&:seq)
  end

  # Assigns total contribution for cake question across all reviewers to a hash map
  # Key : question_id, Value : total score for cake question
  def get_total_cake_score(response,participant,assignment)
    reviewee = ResponseMap.select(:reviewee_id, :type).where(id: response.map_id.to_s).first
    total_score = Cake.get_total_score_for_questions(reviewee.type,
                                                      @review_questions,
                                                      participant.id,
                                                      assignment.id,
                                                      reviewee.reviewee_id)
    return total_score
  end

  # This method is used to send email from a Reviewer to an Author.
  # Email body and subject are inputted from Reviewer and passed to send_mail_to_author_reviewers method in MailerHelper.
  def send_email
    subject = params['send_email']['subject']
    body = params['send_email']['email_body']
    response = params['response']
    email = params['email']

    respond_to do |format|
      if subject.blank? || body.blank?
        flash[:error] = 'Please fill in the subject and the email content.'
        format.html { redirect_to controller: 'response', action: 'author', response: response, email: email }
        format.json { head :no_content }
      else
        # make a call to method invoking the email process
        MailerHelper.send_mail_to_author_reviewers(subject, body, email)
        flash[:success] = 'Email sent to the author.'
        format.html { redirect_to controller: 'student_task', action: 'list' }
        format.json { head :no_content }
      end
    end
  end

  # only two types of responses more should be added
  def email(partial = 'new_submission')
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
    defn[:subject] = 'A new submission is available for ' + parent.name
    response_map.email(defn, participant, parent)
  end

  def notify_instructor_on_difference
    response_map = map
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
        new_score: aggregate_questionnaire_score.to_f / maximum_score,
        assignment: assignment,
        conflicting_response_url: 'https://expertiza.ncsu.edu/response/view?id=' + response_id.to_s,
        summary_url: 'https://expertiza.ncsu.edu/grades/view_team?id=' + reviewee_participant.id.to_s,
        assignment_edit_url: 'https://expertiza.ncsu.edu/assignments/' + assignment.id.to_s + '/edit'
      }
    ).deliver_now
  end

  # compare the current response score with other scores on the same artifact, and test if the difference
  # is significant enough to notify instructor.
  # Precondition: the response object is associated with a ReviewResponseMap
  ### "map_class.assessments_for" method need to be refactored
  def significant_difference?
    map_class = map.class
    existing_responses = map_class.assessments_for(map.reviewee)
    average_score_on_same_artifact_from_others, count = Response.avg_scores_and_count_for_prev_reviews(existing_responses, self)
    # if this response is the first on this artifact, there's no grade conflict
    return false if count.zero?

    # This score has already skipped the unfilled scorable question(s)
    score = aggregate_questionnaire_score.to_f / maximum_score
    questionnaire = questionnaire_by_answer(scores.first)
    assignment = map.assignment
    assignment_questionnaire = AssignmentQuestionnaire.find_by(assignment_id: assignment.id, questionnaire_id: questionnaire.id)
    # notification_limit can be specified on 'Rubrics' tab on assignment edit page.
    allowed_difference_percentage = assignment_questionnaire.notification_limit.to_f
    # the range of average_score_on_same_artifact_from_others and score is [0,1]
    # the range of allowed_difference_percentage is [0, 100]
    (average_score_on_same_artifact_from_others - score).abs * 100 > allowed_difference_percentage
  end
end
