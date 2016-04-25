module SurveyParticipantHelper

def self.get_assigned_survey_students(deployment)
    joiners = SurveyParticipant.where( ["survey_deployment_id = ?", deployment])
    assigned_students = []
    for joiner in joiners
      d = SurveyDeployment.find(deployment)
      student1 = Participant.where("user_id = ? and parent_id = ? and type = ?",joiner.user_id,d.course_id,"CourseParticipant")
      assigned_students << student1[0]
    end
      return assigned_students
  end

end
