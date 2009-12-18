class QuestionnaireWeight < ActiveRecord::Base
   # The assignment to which this weight belongs
   belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'assignment_id'
   belongs_to :questionnaire, :class_name => 'Questionnaire', :foreign_key => 'questionnaire_id'
end
