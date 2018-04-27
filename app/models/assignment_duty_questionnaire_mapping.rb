class AssignmentDutyQuestionnaireMapping < ActiveRecord::Base
	def self.get_questionnaire_id(assignment_id)
		assignment_questionnaire_obj = AssignmentQuestionnaire.where(assignment_id: assignment_id).pluck(:questionnaire_id)
		assignment_questionnaire_obj[2]
	end
end

