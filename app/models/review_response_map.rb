class ReviewResponseMap < ResponseMap
  belongs_to :reviewee, :class_name => 'Team', \
             :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', \
             :foreign_key => 'reviewee_id'
  belongs_to :assignment, :class_name => 'Assignment', \
             :foreign_key => 'reviewed_object_id'

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

  #Delete FeedbackResponseMap and MetareviewResponseMap related to current objects id
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
    mappings = mappings.sort { |a, b| a.reviewee.name <=> b.reviewee.name }
    mappings.each do
    |map|
      csv << [map.reviewee.name, map.reviewer.name]
    end
  end

  #Imports new reponse maps if they do not already exist
  def self.import(row, _session, id)
    if row.length < 2
      raise ArgumentError, 'Not enough items'
    end
    assignment = find_assignment(id)
    index = 1
    reviewee_name = row[0]
    while index < row.length
      reviewee_id = nil
      reviewer_name = row[index]
      reviewer = get_assignment_participant(reviewer_name,  assignment.id, "reviewer")
      participant_nil?(reviewer, reviewer_name , "reviewer")
      #Find reviewee if assignment is a team assignment
      if assignment.team_assignment
        reviewee = AssignmentTeam.where(name: reviewee_name .to_s.strip, parent_id: assignment.id).first
        participant_nil?(reviewee, reviewee_name, "author")
        reviewee_id = reviewee.id
      #Find reviewee if assignment is not a team assignment
      else
	reviewee = get_assignment_participant(reviewee_name, assignment.id, "reviewee")
        participant_nil?(reviewee, reviewee_name, "author")
        reviewee_id  = TeamsUser.team_id(reviewee.parent_id, reviewee.user_id)
      end
      create_response_map(reviewer, reviewee_id,  assignment)
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
  def get_metareview_response_maps
    responses = Response.where(map_id: id)
    metareview_response_maps = []
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
      maps = ResponseMap.where(reviewee_id: team.id, type: 'ReviewResponseMap')
      maps.each do |map|
        unless map.response.empty? && map.response.reject { |r| r.round != round }.empty?
          responses << map.response.reject { |r| r.round != round }.last
        end
      end
      responses.sort! { |a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end

  # wrap The latest version of responses in each response map,
  # together with the questionnaire_id will be used to
  # display the reviewer summary
  def self.final_versions_from_reviewer(reviewer_id)
    maps = ReviewResponseMap.where(reviewer_id: reviewer_id)
    assignment = find_assignment(Participant.find(reviewer_id).parent_id)
    review_final_versions = {}
    unless assignment.varying_rubrics_by_round?
      #same review rubric used in multiple rounds
      review_final_versions = review_final_version_responses(:review, :questionnaire_id, assignment, maps)
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


  # Check for if assignment value is null
  def self.find_assignment(id)
    begin
      assignment = Assignment.find(id)
    rescue ActiveRecord::RecordNotFound
      raise ImportError, "The assignment with id \"#{id}\" was not found.<a href='/assignment/new'>Create</a> this assignment?"
    end
  end

  # Check for if participant is null
  def self.participant_nil?(participant, user_name, participant_type) 
    error_message = nil
    if participant_type == "author"
	error_message = "The author \"#{user_name.to_s.strip}\" was not found.
			 <a href='/users/new'>Create</a> this user?"
    else
    	error_message =  "The reviewer \"#{user_name}\" is not a participant in this assignment.
			 <a href='/users/new'>Register</a> this user as a participant?"
    end
    check_nil?(participant, error_message)
  end

  # Check for if user is null
  def self.user_nil?(user, user_name, user_type)
    check_nil?( user, "The user account for the \"#{user_type}\" \"#{user_name}\" was not found.
			 <a href='/users/new'>Create</a> this user?")
  end

 #Throws import error for nil objects
  def self.check_nil?(object, error_message)
    if object.nil?
       raise ImportError, error_message
    end
  end

  #Find a participant for a specific assignment
  def self.get_assignment_participant(user_name, assignment_id, user_type)
      user = User.find_by_name(user_name.to_s.strip)
      user_nil?(user, user_name, user_type)
      participant = AssignmentParticipant.where(user_id: user.id, parent_id: assignment_id).first
  end

  # Check if review already exists, if not, create new one
  def self.create_response_map(reviewer, team_id, assignment)
    existing = ReviewResponseMap.where(reviewee_id: team_id, reviewer_id: reviewer.id).first
    if existing.nil?
      ReviewResponseMap.create(reviewer_id: reviewer.id, \
			  reviewee_id: team_id, \
			  reviewed_object_id: assignment.id)
    end
  end

  # Compute list of responses and return it
  def self.review_final_version_responses(symbol, questionnaire_id, assignment, maps, round = nil)
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
