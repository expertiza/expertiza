class AssignmentQuestionnaires < ActiveRecord::Base
  belongs_to :assignments, :class_name => "Assignment", :foreign_key => "assignment_id"
  belongs_to :questionnaires, :class_name => "Questionnaire", :foreign_key => "questionnaire_id"
end
