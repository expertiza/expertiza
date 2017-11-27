class Badge < ActiveRecord::Base
	def self.get_id_from_name(badge_name)
  		badge = Badge.where(:name => badge_name)[0]
	  	badge.id
	end

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
		# scores = Badge.get_scores(assignment)
		
		participants.each do |participant|
			badge_matrix.push([false] * NUMBER_OF_BADGES)
			
			print "Badge matrix"

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

end