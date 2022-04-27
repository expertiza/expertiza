module ResponseHelper
  # E2218: this module contains methods that are used in response_controller class

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
    new_response ? questionnaire_from_response_map : questionnaire_from_response
    set_dropdown_or_scale
    new_response ? set_questions_for_new_response : set_questions
    # @review_questions = sort_questions(@questionnaire.questions)
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
    # The new response is created here so that the controller has access to it in the new method
    # This response object is populated later in the new method
    if new_response
      @response = Response.create(map_id: @map.id, additional_comment: '', round: @current_round, is_submitted: 0)
    end
  end

  def set_questions_for_new_response
    @review_questions = sort_questions(@questionnaire.questions)
    if (@assignment && @assignment.is_revision_planning_enabled)
      reviewees_topic = SignedUpTeam.topic_id_by_team_id(@contributor.id)
      current_round = @assignment.number_of_current_round(reviewees_topic)
      @revision_plan_questionnaire = RevisionPlanTeamMap.find_by(team_id: @map.reviewee_id, used_in_round: current_round).try(:questionnaire)
      if (@revision_plan_questionnaire)
        @review_questions += sort_questions(@revision_plan_questionnaire.questions)
      end
    end
    return @review_questions
  end

  def set_questions
    @review_questions = []
    answers = @response.scores
    questionnaires = @response.questionnaires_by_answers(answers)
    questionnaires.each { |questionnaire| @review_questions += sort_questions(questionnaire.questions).sort_by(&:seq) }
    return @review_questions
  end
end
