class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant
end
