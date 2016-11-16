class Badge
	attr_accessor :user

	NUMBER_OF_BADGES = 5
	GOOD_REVIEW_THRESHOLD = 95

	def self.get_badges(assignment_list)
		
		# create badge matrix
		current_assignment_count = 0
		#badge_matrix_row = [false] * NUMBER_OF_BADGES
		badge_matrix = []

		assignment_list.each do |assignment|
			participant = assignment.participant
			
			# insert a new row in badge matrix
			badge_matrix.push([false] * NUMBER_OF_BADGES)

			# check for different badges

			# Good reviewer badge
			badge_matrix[current_assignment_count][2] = Badge.good_reviewer(participant)

			current_assignment_count = current_assignment_count + 1
		end

		return badge_matrix
	
	end

	private

	def self.good_reviewer(participant)
		if participant.try(:grade_for_reviewer).nil? or participant.try(:comment_for_reviewer).nil?
		      info = -1
		else
		      info = participant.try(:grade_for_reviewer)
		end

		if info >= GOOD_REVIEW_THRESHOLD
			return true
		else
			return false
		end
	end

end