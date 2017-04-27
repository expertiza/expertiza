module SurveyDeploymentHelper
	def get_responses_for_question_in_a_survey_deployment(q_id,sd_id)
		question = Question.find(q_id)
		responses = []
			@range_of_scores.each do |i|
				responses << SurveyResponse.where(question_id: question.id, score: i, survey_deployment_id: sd_id).count	
			end
		responses
	end
end