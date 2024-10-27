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

  # This method is called within set_content and when the new_response flag is set to true
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

  # E-1973 - helper method to check if the current user is the reviewer
  # if the reviewer is an assignment team, we have to check if the current user is on the team
  def current_user_is_reviewer?(map, _reviewer_id)
    map.reviewer.current_user_is_reviewer? current_user.try(:id)
  end

  # sorts the questions passed by sequence number in ascending order
  def sort_questions(questions)
    questions.sort_by(&:seq)
  end

  # Assigns total contribution for cake question across all reviewers to a hash map
  # Key : question_id, Value : total score for cake question
  def store_total_cake_score
    reviewee = ResponseMap.select(:reviewee_id, :type).where(id: @response.map_id.to_s).first
    @total_score = Cake.get_total_score_for_questions(reviewee.type,
                                                      @review_questions,
                                                      @participant.id,
                                                      @assignment.id,
                                                      reviewee.reviewee_id)
  end

  # new_response if a flag parameter indicating that if user is requesting a new rubric to fill
  # if true: we figure out which questionnaire to use based on current time and records in assignment_questionnaires table
  # e.g. student click "Begin" or "Update" to start filling out a rubric for others' work
  # if false: we figure out which questionnaire to display base on @response object
  # e.g. student click "Edit" or "View"
  def set_content(new_response = false)
    @title = @map.get_title
    if @map.survey?
      @survey_parent = @map.survey_parent
    else
      @assignment = @map.assignment
    end
    @participant = @map.reviewer
    @contributor = @map.contributor
    new_response ? questionnaire_from_response_map(@map,@contributor,@assignment) : questionnaire_from_response(@response)
    set_dropdown_or_scale
    @review_questions = sort_questions(@questionnaire.questions)
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
    # The new response is created here so that the controller has access to it in the new method
    # This response object is populated later in the new method
    if new_response
      #Sometimes the response is already created and the new controller is called again (page refresh)
      @response = Response.where(map_id: @map.id, round: @current_round.to_i).order(updated_at: :desc).first
      if @response.nil?
        @response = Response.create(map_id: @map.id, additional_comment: '', round: @current_round.to_i, is_submitted: 0)
      end
    end
  end
end
