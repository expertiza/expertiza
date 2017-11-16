class AwardedBadge < ActiveRecord::Base
  belongs_to :badge, foreign_key: :badge_id
  belongs_to :participant, foreign_key: :participant_id
end
