class GlobalSurveyMap < ActiveRecord::Base
  belongs_to :course
  belongs_to :questionnaire
  has_paper_trail
end
