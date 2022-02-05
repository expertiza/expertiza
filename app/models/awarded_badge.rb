class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant

  def approved?
    approval_status == 1
  end
end
