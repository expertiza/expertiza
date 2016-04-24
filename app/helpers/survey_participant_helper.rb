module SurveyParticipantHelper

def self.get_assigned_survey_students(deployment)
    joiners = SurveyParticipant.where( ["survey_deployment_id = ?", deployment])
    assigned_students = []
    for joiner in joiners
      d = SurveyDeployment.find(deployment)
      student = Participant.where("user_id = ? and parent_id = ?",joiner.user_id,d.course_id)
      assigned_students << student[0]
    end
  end

end
