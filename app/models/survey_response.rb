class SurveyResponse < ActiveRecord::Base
 belongs_to :assignment
 belongs_to :rubric
 belongs_to :question
 
 validates_numericality_of :score
end
