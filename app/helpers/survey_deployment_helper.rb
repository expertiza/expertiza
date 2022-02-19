module SurveyDeploymentHelper
  # Returns an array containing the number of responses for a question in a survey deployment
  def get_responses_for_question_in_a_survey_deployment(q_id, sd_id)
    question = Question.find(q_id)
    responses = []
    type_of_response_map = %w[AssignmentSurveyResponseMap CourseSurveyResponseMap GlobalSurveyResponseMap]
    response_map_list = ResponseMap.find_by_sql(['SELECT * FROM response_maps WHERE ' \
      'reviewee_id = ? AND (type = ? OR type = ? OR type = ?)', sd_id, type_of_response_map[0], type_of_response_map[1], type_of_response_map[2]])
    @range_of_scores.each do |i|
      count = 0
      response_map_list.each do |response_map|
        response_list = Response.where(map_id: response_map.id)
        response_list.each do |response|
          count += Answer.where(question_id: question.id, answer: i, response_id: response.id).count
        end
      end
      responses << count
    end
    responses
  end

  # Statistics are displayed only for Criterion and Checkbox type questions
  def allowed_question_type?(question)
    question.type == 'Criterion' || question.type == 'Checkbox'
  end
end
