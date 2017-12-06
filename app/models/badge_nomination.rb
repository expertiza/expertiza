class BadgeNomination < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :participant
  belongs_to :badge
end
