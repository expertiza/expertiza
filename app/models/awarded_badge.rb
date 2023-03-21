class AwardedBadge < ApplicationRecord
  belongs_to :badge
  belongs_to :participant

  def approved?
    approval_status == 1
  end

  # E2218: This method is called when a badge is awarded to a participant
  # This method is called from response controller
  def award_badge(participant_id, badge_name)
    badge_id = Badge.get_id_from_name(badge_name: badge_name)
    AwardedBadge.where(participant_id: participant_id, badge_id: badge_id, approval_status: 0).first_or_create
  end
end
