class Badge
	
	NUMBER_OF_BADGES = 5
	
	# CONSTANTS RELATED TO GOOD REVIEWER
	GOOD_REVIEW_THRESHOLD = 95
	GOOD_REVIEWER_BADGE_IMAGE = "<img id='good_reviewer_badge' src='/assets/badges/good_reviewer_badge.png' title = 'Good Reviewer'>"

	TOPPER_BADGE_IMAGE = "<img id='topper_badge' src='/assets/badges/topper_badge.png' title = 'Top Score'>"

	def self.get_badges(student_task_list)
		
		# create badge matrix
		current_assignment_count = 0
		badge_matrix = []

		student_task_list.each do |student_task|
			participant = student_task.participant
			
			# insert a new row in badge matrix
			badge_matrix.push([false] * NUMBER_OF_BADGES)

			# check for different badges

			# Topper badge
			badge_matrix[current_assignment_count][0] = Badge.topper(student_task)

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
			return GOOD_REVIEWER_BADGE_IMAGE.html_safe
		else
			return false
		end
	end

	def self.topper(student_task)
		assignment = student_task.assignment
		questions = {}
	    questionnaires = assignment.questionnaires

	    if assignment.varying_rubrics_by_round?
	      questions = Badge.retrieve_questions(questionnaires, assignment)
	    else # if this assignment does not have "varying rubric by rounds" feature
	      questionnaires.each do |questionnaire|
	        questions[questionnaire.symbol] = questionnaire.questions
	      end
	    end

	    scores = assignment.scores(questions)
	    # averages = Badge.calculate_average_vector(assignment.scores(questions))
	    averages = Badge.calculate_average_vector(scores)
	    teams = Badge.get_teams(scores)
	    # avg_of_avg = Badge.mean(averages)
	    # return TOPPER_BADGE_IMAGE.html_safe
	    max_average_index = averages.each_with_index.max[1]

	    # return teams[max_average_index].get_author_names.include(student_task.participant.name)
	 	if teams[max_average_index].participants.include?(student_task.participant)
			return TOPPER_BADGE_IMAGE.html_safe
	 	else
	 		return false
	 	end
	end

	def self.topper2(student_task)
		assignment = student_task.assignment
		assignment_participant = student_task.participant

		questions = {}
	    questionnaires = assignment.questionnaires

	    if assignment.varying_rubrics_by_round?
	      questions = Badge.retrieve_questions(questionnaires, assignment)
	    else # if this assignment does not have "varying rubric by rounds" feature
	      questionnaires.each do |questionnaire|
	        questions[questionnaire.symbol] = questionnaire.questions
	      end
	    end

	    scores = assignment_participant.scores(questions)

		return scores
	end

	def self.retrieve_questions(questionnaires, assignment)
		questions = {}
	    questionnaires.each do |questionnaire|
	      round = AssignmentQuestionnaire.where(assignment_id: assignment.id, questionnaire_id: questionnaire.id).first.used_in_round
	      questionnaire_symbol = if (!round.nil?)
	        (questionnaire.symbol.to_s+round.to_s).to_sym
	      else
	        questionnaire.symbol
	                             end
	      questions[questionnaire_symbol] = questionnaire.questions
	    end
	    return questions
  end

  def self.calculate_average_vector(scores)
    scores[:teams].reject! {|_k, v| v[:scores][:avg].nil? }
    scores[:teams].map {|_k, v| v[:scores][:avg].to_i }
  end

  def self.mean(array)
    array.inject(0) {|sum, x| sum += x } / array.size.to_f
  end

  def self.get_teams(hash)
  	teams = []
  	hash[:teams].reject! {|_k, v| v[:scores][:avg].nil? }
  	keys = hash[:teams].collect {|key,value| key}
  	keys.each do |key|
  		teams.push((hash[:teams][key][:team])) 
  	end
  	# scores[:teams][index.to_s.to_sym][:team] = team
  	return teams
  end

end