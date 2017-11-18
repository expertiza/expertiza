class Badge < ActiveRecord::Base

	NUMBER_OF_BADGES = 2
	
	# CONSTANTS RELATED TO GOOD REVIEWER
	GOOD_REVIEW_THRESHOLD = 75
	GOOD_REVIEWER_BADGE_IMAGE = "<img height = 'auto' width = '50px' src='/assets/badges/goodReviewer.png'/>"

	
	GOOD_TEAMMATE_THRESHOLD = 0.75
	GOOD_TEAMMATE_IMAGE = "<img height = 'auto' width = '50px' src='/assets/badges/goodTeammate.png'/>"


	def self.get_badges_student_view(student_task_list)
		
		# create badge matrix
		current_assignment_count = 0
		badge_matrix = []
		consistency_flag = true

		student_task_list.each do |student_task|
			# insert a new row in badge matrix
			badge_matrix.push([false] * NUMBER_OF_BADGES)

			if not student_task.assignment.is_calibrated
			# check for different badges
			
			# Good reviewer badge
			badge_matrix[current_assignment_count][0] = Badge.good_reviewer(student_task.participant)
			
			# Good teammate badge
			badge_matrix[current_assignment_count][1] = Badge.good_teammate(student_task.assignment, student_task.participant)

			end

			current_assignment_count = current_assignment_count + 1
		end
		return badge_matrix
	end

	def self.get_badges_instructor_view(participants, assignment)
		current_assignment_count = 0
		badge_matrix = []
		scores = Badge.get_scores(assignment)
		
		participants.each do |participant|
			badge_matrix.push([false] * NUMBER_OF_BADGES)
			

			if not assignment.is_calibrated and participant.user.role.name=="Student"
			# check for different badges

			# Good reviewer badge
			badge_matrix[current_assignment_count][0] = Badge.good_reviewer(participant)

			# Good teammate badge
			badge_matrix[current_assignment_count][0] = Badge.good_teammate(assignment, participant)

			end

			current_assignment_count = current_assignment_count + 1			

		end

		return badge_matrix
	end


	private


	def self.good_reviewer(participant)
		begin
			print "hello"
			r = ReviewGrade.where(participant_id: participant.id)[0]
			grade_for_reviewer = r.grade_for_reviewer
			comment_for_reviewer = r.comment_for_reviewer 
			if grade_for_reviewer.nil? or comment_for_reviewer.nil?
			      info = -1
			else
			      info = grade_for_reviewer
			end

			if info >= GOOD_REVIEW_THRESHOLD
				return GOOD_REVIEWER_BADGE_IMAGE.html_safe
			else
				print info
				print "info < threshold"
				return false
			end
		rescue
			print "rescue"
			return false
		end
	end


def self.good_teammate(assignment, participant)
		
	
	team = participant.team
	
	if team.nil?
		return false
	end

	begin
		team_participants = team.participants
		scores = {}

	 	team_participants.each do |teammate|
		 	teammate_reviews = teammate.teammate_reviews
		 	teammate_reviews.each do |teammate_review|
		 			key = teammate_review.reviewee.name
		 			if scores.key?(key)
		 				scores[key] = scores[key] + (teammate_review.get_total_score.to_f/teammate_review.get_maximum_score.to_f)
		 			else
		 				scores[key] = 0.0
		 				scores[key] = scores[key] + (teammate_review.get_total_score.to_f/teammate_review.get_maximum_score.to_f)
		 			end	
		 		end
	 	end

	 	total_reviews_per_teammate = scores.length - 1
	 	team_participants.each do |teammate|
	 		key = teammate.name
	 		scores[key] = scores[key]/total_reviews_per_teammate
	 	end
	 	
	 	badge = true 

	 	team_participants.each do |teammate|
	 		key = teammate.name
	 		if scores[key] < DREAM_TEAM_THRESHOLD
				badge = false
				break
			end
		end

		if badge
			return DREAM_TEAM_BADGE_IMAGE.html_safe
		else
			return false
		end
	rescue
		return false
	end

end

  
end