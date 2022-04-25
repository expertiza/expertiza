class RevisionPlanTeamMap < ActiveRecord::Base
    belongs_to :team
    belongs_to :questionnaire
  end