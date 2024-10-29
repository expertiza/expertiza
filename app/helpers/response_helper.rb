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
end
