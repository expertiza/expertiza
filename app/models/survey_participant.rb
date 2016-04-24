class SurveyParticipant < ActiveRecord::Base
   validates_presence_of :survey_deployment_id
   validates_presence_of :user_id
   validate :validate_survey_participant
   
   def validate_survey_participant
       user = User.find_by(id: user_id)
       if user.role_id != Role.student.id
         errors.add_to_base("Participant should be a student.")
       end
   end
end
