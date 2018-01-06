class AssignmentBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :assignment

  def self.get_threshold(name, assignment_id)
    badge_id = Badge.get_id_from_name(name) 
    AssignmentBadge.find_by(assignment_id: assignment_id, badge_id: badge_id).try(:threshold)
  end

  def self.save_badge_populate_awarded_badges(badge_threshold_hash, assignment_id)
  	if AssignmentBadge.exists?(assignment_id: assignment_id)
  		update_badge(badge_threshold_hash, assignment_id)
  	else
  		create_badge(badge_threshold_hash, assignment_id)
  	end
    AwardedBadge.award_good_reviewer_badge(assignment_id)
    AwardedBadge.award_good_teammate_badge(assignment_id)
  end

  # Store in the model entry with appropriate values - First time call
  def self.create_badge(badge_threshold_hash, assignment_id)
    badge_threshold_hash.each do |badge_name, threshold|
      badge_id = Badge.get_id_from_name(name)
      AssignmentBadge.create(badge_id: badge_id, assignment_id: assignment_id, threshold: threshold)
    end
  end

  def self.update_badge(badge_threshold_hash, assignment_id)
    AssignmentBadge.where(assignment_id: assignment_id).each do |assignment_badge|
      badge = assignment_badge.badge
      assignment_badge.update_attributes(threshold: badge_threshold_hash[badge.try(:name)])
    end
  end
end
