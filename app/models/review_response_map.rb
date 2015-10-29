class ReviewResponseMap < ResponseMap
	 belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
	 belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'
	 belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'reviewed_object_id'
	
	 # In if this assignment uses "varying rubrics" feature,
	 # the "used_in_round" field should not be nil
	 # so find the round # based on current time and the due
	 # date times, and use that round to find corresponding
	 # questionnaire_id from assignment_questionnaires table
	 # otherwise this assignment does not use the
	 # "varying rubrics", so in assignment_questionnaires table
	 # there should be only 1 questionnaire with type
	 # 'ReviewQuestionnaire'. -Yang
	 def questionnaire(round)
	 	if self.assignment.varying_rubrics_by_round?
	 		Questionnaire.find(assignment.get_review_questionnaire_id(round))
	 	else
	 		Questionnaire.find(assignment.get_review_questionnaire_id)
	 	end
	 end
	
	 def get_title
	 	'Review'
	 end
	
	 def delete(force = nil)
	   	 fmaps = FeedbackResponseMap.where(reviewed_object_id: id)
		 fmaps.each { |fmap| fmap.delete(true) }
		 maps = MetareviewResponseMap.where(reviewed_object_id: id)
		 maps.each { |map| map.delete(force) }
		 destroy
	 end
	
	 # options parameter used as a signature in other models
	 def self.export_fields(options)
	 	 fields = ['contributor', 'reviewed by']
		 fields
	 end
	
	 # options parameter used as a signature in other models
	 def self.export(csv, parent_id, options)
	 	mappings = where(reviewed_object_id: parent_id)
		 mappings.sort! { |a, b| a.reviewee.name <=> b.reviewee.name }
		 mappings.each do
			 |map|
			 csv << [ map.reviewee.name, map.reviewer.name ]
		 end
	 end
	
	 def self.import(row, _session, id)
	 	if row.length < 2
	 		raise ArgumentError, 'Not enough items'
	 	end
	 	assignment = find_assignment(id)
	 	index = 1
		 while index < row.length
			 user = User.find_by_name(row[index].to_s.strip)
			 reviewer_user_nil(user, row, index)
			 reviewer = AssignmentParticipant.where(user_id: user.id, parent_id: assignment.id).first
			 reviewer_nil(reviewer, row, index)
			 if assignment.team_assignment
				 reviewee = AssignmentTeam.where(name: row[0].to_s.strip, parent_id: assignment.id).first
				 reviewee_nil(reviewee, row)
				 existing = ReviewResponseMap.where(reviewee_id: reviewee.id,
				 reviewer_id: reviewer.id).first
				 existing_nil(reviewer, reviewee.id, assignment)
			 else
				 puser = User.find_by_name(row[0].to_s.strip)
				 reviewee_user_nil(user, row)
				 reviewee = AssignmentParticipant.where(user_id: puser.id,
				 parent_id: assignment.id).first
				 reviewee_nil(reviewee, row)
	 			 team_id = TeamsUser.team_id(reviewee.parent_id, reviewee.user_id)
				 existing_nil(reviewer, team_id, assignment)
			 end
			 index += 1
		 end
	 end
	
	 # Map to display the feedback response
	 def show_feedback(response)
	 	if (!self.response.empty? && response)
			 map = FeedbackResponseMap.find_by_reviewed_object_id(response.id)
			 if map && !map.response.empty?
				 map.response.last.display_as_html
			 end
		 end
	 end
	
	 # This method adds a new entry in the ResponseMap
	 def self.add_reviewer(contributor_id, reviewer_id, assignment_id)
	 	if where(reviewee_id: contributor_id, reviewer_id: reviewer_id).count > 0
			 create(reviewee_id: contributor_id, reviewer_id: reviewer_id, reviewed_object_id: assignment_id)
		 else
			 raise "The reviewer, \"" + reviewer.name + "\", is already assigned to this contributor."
		 end
	 end
	
	 # Returns the response maps for all the metareviews
	 def metareview_response_maps
	 	responses = Response.where(map_id: id)
		 #check for nil
		 responses.each do |response|
			 metareview_response_maps << MetareviewResponseMap.where(reviewed_object_id: response.id)
		 end
		 metareview_response_maps
	 end
	
	 # return the responses for specified round,
	 # for varying rubric feature -Yang
	 def self.get_team_responses_for_round(team, round)
		 responses = []
		 if team.id
			 maps = ResponseMap.where(reviewee_id: team.id,	 type: 'ReviewResponseMap')
			 maps.each do |map|
				 unless map.response.empty? && map.response.reject { |r| r.round != round }.empty?
					 responses << map.response.reject { |r| r.round != round }.last
				 end
			 end
			 responses.sort! {|a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname}
		 end
		 responses
	 end
	
	 # wrap The latest version of responses in each response map,
	 # together with the questionnaire_id will be used to
	 # display the reviewer summary
	 def self.final_versions_from_reviewer(reviewer_id)
	 	maps = ReviewResponseMap.where(reviewer_id: reviewer_id)
		 assignment = Assignment.find(Participant.find(reviewer_id).parent_id)
		 review_final_versions = {}
		 unless assignment.varying_rubrics_by_round?
			 #same review rubric used in multiple rounds
			 review_final_versions =	 review_final_version_responses(:review, :questionnaire_id, assignment, maps)
		 else
			 # vary rubric by round
			 rounds_num = assignment.rounds_of_reviews
			 (1..rounds_num).each do |round|
				 symbol = ('review round' + round.to_s).to_sym
				 review_final_versions = review_final_version_responses(symbol, :questionnaire_id, assignment, maps, round)
			 end
		 end
		 review_final_versions
	 end
	
	 
	private
	

	 # Check for if user value for reviewer is null
	 def self.reviewer_user_nil(user, row, index)
		 if user.nil?
			 raise ImportError, "The user account for the reviewer \"#{row[index]}\" was not found. <a href='/users/new'>Create</a> this user?"
		 end
	 end
	
	 # Check for if user value for reviewee is null
	 def self.reviewee_user_nil(user, row)
		 if user.nil?
		 raise ImportError, "The user account for the reviewee \"#{row[0]}\" was not found.
			 <a href='/users/new'>Create</a> this user?"
		 end
	 end
	
	 # Check for if assignment value is null
	 def self.find_assignment(id)
		begin
			assignment = Assignment.find(id)
	 	rescue ActiveRecord::RecordNotFound
		 	raise ImportError, "The assignment with id \"#{id}\" was not found.<a href='/assignment/new'>Create</a> this assignment?"
		end
	 end
	
	 # Check for if reviewer value is null
	 def self.reviewer_nil(reviewer, row, index)
	 	if reviewer.nil?
		 raise ImportError, "The reviewer \"#{row[index]}\" is not a participant in this assignment.
			 <a href='/users/new'>Register</a> this user as a participant?"
		 end
	 end
	
	 # Check for if reviewee value is null
	 def self.reviewee_nil(reviewee, row)
	 	if reviewee.nil?
			 raise ImportError,	 "The author \"#{row[0].to_s.strip}\" was not found.
			 <a href='/users/new'>Create</a> this user?"
		 end
	 end
	
	 # Check for if review already exists, if not, create new one
	 def self.existing_nil(reviewer, team_id, assignment)
		existing = ReviewResponseMap.where(reviewee_id: team_id, reviewer_id: reviewer.id).first
		if existing.nil?
			 ReviewResponseMap.create(reviewer_id: reviewer.id, \
			 reviewee_id: team_id, \
			 reviewed_object_id: assignment.id)
		end
	 end
	
	 # Compute list of responses and return it
	 def review_final_version_responses(symbol, questionnaire_id,
	 	assignment, maps, round = nil)
		 review_final_versions = {}
		 review_final_versions[symbol] = {}
		 review_final_versions[symbol][questionnaire_id] = assignment.get_review_questionnaire_id(round)
		 response_ids = []
		 maps.each do |map|
			 if round.nil?
				 responses = Response.where(map_id: map.id)
			 else
				 responses = Response.where(map_id: map.id, round: round)
			 end
			 unless responses.empty?
				 response_ids << responses.last.id
			 end
		end
		 review_final_versions[symbol][:response_ids] = response_ids
	 end
	
end
