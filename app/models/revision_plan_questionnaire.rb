class RevisionPlanQuestionnaire < ActiveRecord::Base
  belongs_to :team
  belongs_to :questionnaire
end
