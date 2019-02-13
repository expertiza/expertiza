class TeamNomination < ActiveRecord::Base
  belongs_to :badge
  belongs_to :team
end
