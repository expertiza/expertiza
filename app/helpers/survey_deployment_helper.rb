module SurveyDeploymentHelper
	# Returns an array containing the number of responses for a question in a survey deployment 
	def get_responses_for_question_in_a_survey_deployment(q_id,sd_id)
		question = Question.find(q_id)
		responses = []
			@range_of_scores.each do |i|
				responses << SurveyResponse.where(question_id: question.id, score: i, survey_deployment_id: sd_id).count	
			end
		responses
	end
	# Statistics are displayed only for Criterion and Checkbox type questions
	def allowed_question_type?(question)
		question.type == "Criterion" || question.type == "Checkbox"
	end
end