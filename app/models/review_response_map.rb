class ReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Team', foreign_key: 'reviewee_id'
  belongs_to :contributor, class_name: 'Team', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  # In if this assignment uses "varying rubrics" feature, the sls
  # "used_in_round" field should not be nil
  # so find the round # based on current time and the due date times, and use that round # to find corresponding
  # questionnaire_id from assignment_questionnaires table
  # otherwise this assignment does not use the "varying rubrics", so in assignment_questionnaires table there should
  # be only 1 questionnaire with type 'ReviewQuestionnaire'.    -Yang
  def questionnaire(round)
    if self.assignment.varying_rubrics_by_round?
      Questionnaire.find(self.assignment.review_questionnaire_id(round))
    else
      Questionnaire.find(self.assignment.review_questionnaire_id)
    end
  end

  def get_title
    "Review"
  end

  def delete(force = nil)
    fmaps = FeedbackResponseMap.where(reviewed_object_id: self.response.response_id)
    fmaps.each {|fmap| fmap.delete(true) }
    maps = MetareviewResponseMap.where(reviewed_object_id: self.id)
    maps.each {|map| map.delete(force) }
    self.destroy
  end

  def self.export_fields(_options)
    fields = ["contributor", "reviewed by"]
    fields
  end

  def self.export(csv, parent_id, _options)
    mappings = where(reviewed_object_id: parent_id).to_a
    mappings.sort! {|a, b| a.reviewee.name <=> b.reviewee.name }
    mappings.each do |map|
      csv << [
        map.reviewee.name,
        map.reviewer.name
      ]
    end
  end

  def self.import(row, _header, _session, assignment_id)
    reviewee_user_name = row[0].strip
    reviewee_user = User.find_by(name: reviewee_user_name)
    raise ArgumentError, "Cannot find reviewee user." if reviewee_user.nil?

    reviewee_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(reviewee_user.id, assignment_id)
    raise ArgumentError, "Reviewee user is not a participant in this assignment." if reviewee_participant.nil?

    reviewee_team = AssignmentTeam.team(reviewee_participant)
    if reviewee_team.nil? # lazy team creation: if the reviewee does not have team, create one.
      reviewee_team = AssignmentTeam.create(name: 'Team' + '_' + rand(1000).to_s,
                                            parent_id: assignment_id, type: 'AssignmentTeam')
      t_user = TeamsUser.create(team_id: reviewee_team.id, user_id: reviewee_user.id)
      team_node = TeamNode.create(parent_id: assignment_id, node_object_id: reviewee_team.id)
      TeamUserNode.create(parent_id: team_node.id, node_object_id: t_user.id)
    end

    index = 1
    while index < row.length
      reviewer_user_name = row[index].strip
      reviewer_user = User.find_by(name: reviewer_user_name)
      raise ArgumentError, "Cannot find reviewer user." if reviewer_user.nil?
      next if reviewer_user_name.empty?

      reviewer_participant = AssignmentParticipant.find_by_user_id_and_assignment_id(reviewer_user.id, assignment_id)
      raise ArgumentError, "Reviewer user is not a participant in this assignment." if reviewer_participant.nil?

      if ReviewResponseMap.find_by(reviewed_object_id: assignment_id, reviewer_id: reviewer_participant.id, reviewee_id: reviewee_team.id, calibrate_to: false).nil?
        ReviewResponseMap.create(reviewed_object_id: assignment_id, reviewer_id: reviewer_participant.id, reviewee_id: reviewee_team.id, calibrate_to: false)
      end

      index += 1
    end
  end

  def show_feedback(response)
    if !self.response.empty? && response
      map = FeedbackResponseMap.find_by_reviewed_object_id(response.id)
      return map.response.last.display_as_html if map and !map.response.empty?
    end
  end

  # This method adds a new entry in the ResponseMap
  def self.add_reviewer(contributor_id, reviewer_id, assignment_id)
    if where(reviewee_id: contributor_id, reviewer_id: reviewer_id).count > 0
      create(reviewee_id: contributor_id,
             reviewer_id: reviewer_id,
             reviewed_object_id: assignment_id)
    else
      raise "The reviewer, \"" + reviewer.name + "\", is already assigned to this contributor."
    end
  end

  def metareview_response_maps
    responses = Response.where(map_id: self.id)
    metareview_list = []
    responses.each do |response|
      metareview_response_maps = MetareviewResponseMap.where(reviewed_object_id: response.id)
      metareview_response_maps.each do |metareview_response_map|
        metareview_list << metareview_response_map
      end
    end
    metareview_list
  end

  # return  the responses for specified round, for varying rubric feature -Yang
  def self.get_responses_for_team_round(team, round)
    responses = []
    if team.id
      maps = ResponseMap.where(reviewee_id: team.id, type: "ReviewResponseMap")
      maps.each do |map|
        if !map.response.empty? && !map.response.reject {|r| (r.round != round || !r.is_submitted) }.empty?
          responses << map.response.reject {|r| (r.round != round || !r.is_submitted) }.last
        end
      end
      responses.sort! {|a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end

  # wrap lastest version of responses in each response map, together withe the questionnaire_id
  # will be used to display the reviewer summary
  def self.final_versions_from_reviewer(reviewer_id)
    maps = ReviewResponseMap.where(reviewer_id: reviewer_id)
    assignment = Assignment.find(Participant.find(reviewer_id).parent_id)
    prepare_final_review_versions(assignment, maps)
  end

  def self.review_response_report(id, assignment, type, review_user)
    if review_user.nil?
      # This is not a search, so find all reviewers for this assignment
      response_maps_with_distinct_participant_id =
        ResponseMap.select("DISTINCT reviewer_id").where(["reviewed_object_id = ? and type = ? and calibrate_to = ?", id, type, 0])
      @reviewers = []
      response_maps_with_distinct_participant_id.each do |reviewer_id_from_response_map|
        @reviewers << AssignmentParticipant.find(reviewer_id_from_response_map.reviewer_id)
      end
      @reviewers = Participant.sort_by_name(@reviewers)
    else
      # This is a search, so find reviewers by user's full name
      user = User.select("DISTINCT id").where(["fullname LIKE ?", '%' + review_user[:fullname] + '%'])
      @reviewers = AssignmentParticipant.where(["user_id IN (?) and parent_id = ?", user, assignment.id])
    end
    #  @review_scores[reveiwer_id][reviewee_id] = score for assignments not using vary_rubric_by_rounds feature
    # @review_scores[reviewer_id][round][reviewee_id] = score for assignments using vary_rubric_by_rounds feature
  end

  def email(defn, _participant, assignment)
    defn[:body][:type] = "Peer Review"
    AssignmentTeam.find(reviewee_id).users.each do |user|
      defn[:body][:obj_name] = assignment.name
      defn[:body][:first_name] = User.find(user.id).fullname
      defn[:to] = User.find(user.id).email
      Mailer.sync_message(defn).deliver_now
    end
  end

  private

  def self.prepare_final_review_versions(assignment, maps)
    review_final_versions = {}
    rounds_num = assignment.rounds_of_reviews
    if !rounds_num.nil? && rounds_num > 1
      (1..rounds_num).each do |round|
        prepare_review_response(assignment, maps, review_final_versions, round)
      end
    else
      prepare_review_response(assignment, maps, review_final_versions, nil)
    end
    review_final_versions
  end

  def self.prepare_review_response(assignment, maps, review_final_versions, round)
    symbol = if round.nil?
               :review
             else
               ("review round" + round.to_s).to_sym
             end
    review_final_versions[symbol] = {}
    review_final_versions[symbol][:questionnaire_id] = assignment.review_questionnaire_id(round)
    response_ids = []
    maps.each do |map|
      where_map = {map_id: map.id}
      where_map[:round] = round unless round.nil?
      responses = Response.where(where_map)
      response_ids << responses.last.id unless responses.empty?
    end
    review_final_versions[symbol][:response_ids] = response_ids
  end
end
