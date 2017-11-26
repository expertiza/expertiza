class AwardedBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :participant
  
  NUMBER_OF_BADGES = 2
  
  GOOD_REVIEWER_BADGE_IMAGE = "<img height = 'auto' width = '50px' src='/assets/badges/goodReviewer.png'/>"
  GOOD_TEAMMATE_IMAGE = "<img height = 'auto' width = '50px' src='/assets/badges/goodTeammate.png'/>"

	def self.get_badges_student_view(student_tasks)
		badge_matrix = []
		current_assignment_count = 0
		consistency_flag = true
		student_tasks.each do |student_task|
			badge_matrix.push([false] * NUMBER_OF_BADGES)
			
			badge_matrix[current_assignment_count][0] = AwardedBadge.good_reviewer(student_task.participant)
			
		  badge_matrix[current_assignment_count][1] = AwardedBadge.good_teammate(student_task.participant)
		
		  
		  current_assignment_count = current_assignment_count + 1;
		 end
		 
		 return badge_matrix
	end
	
	def self.good_reviewer(participant)
		badge = AwardedBadge.where(participant_id: participant.id, badge_id: 1)
		if !badge.empty?
				return GOOD_REVIEWER_BADGE_IMAGE.html_safe
		end
		return false
	end
	
	def self.good_teammate(participant)
		badge = AwardedBadge.where(participant_id: participant.id, badge_id: 2)
		if !badge.empty?
				return GOOD_TEAMMATE_IMAGE.html_safe
		end
		return false
	end
end
