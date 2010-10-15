class SurveyResponse < ActiveRecord::Base
 belongs_to :assignment
 belongs_to :questionnaire
 belongs_to :question
 
end
