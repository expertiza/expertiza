module SurveyParticipantHelper

def self.get_assigned_survey_students(deployment)
    joiners = SurveyParticipant.where( ["survey_deployment_id = ?", deployment])
    assigned_students = []
    for joiner in joiners
      student = User.find(joiner.user_id)
      assigned_students << student
    end
  end

end
