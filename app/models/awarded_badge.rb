class AwardedBadge < ApplicationRecord
  belongs_to :badge
  belongs_to :participant

  def approved?
    self.approval_status == 1
  end
end
