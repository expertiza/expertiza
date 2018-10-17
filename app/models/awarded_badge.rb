class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant

  def is_approved?
    self.approval_status == 1
  end
end
