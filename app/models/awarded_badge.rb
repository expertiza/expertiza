class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant

	def self.award(participant_id, assignment_id, grade_for_reviewer, badge_name)
		print "In AwardedBadge _____________________________"
		badge_id = Badge.get_id_from_name(badge_name)
		# assignmentBadge = AssignmentBadge.where(:badge_id => badge_id,:assignment_id => assignment_id)
		assignmentBadge = AssignmentBadge.where("badge_id = ? AND assignment_id = ?",badge_id,assignment_id)
		print assignmentBadge.empty?
		if !assignmentBadge.empty? and grade_for_reviewer.to_i >= assignmentBadge[0].threshold
			a = AwardedBadge.new(:participant_id => participant_id, :assignment_id => assignment_id, :badge_id => badge_id)
			a.save!
		end
	end

end
