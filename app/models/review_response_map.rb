class ReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Team', foreign_key: 'reviewee_id', inverse_of: false
  belongs_to :contributor, class_name: 'Team', foreign_key: 'reviewee_id', inverse_of: false
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id', inverse_of: false

  # In if this assignment uses "varying rubrics" feature, the sls
  # "used_in_round" field should not be nil
  # so find the round # based on current time and the due date times, and use that round # to find corresponding
  # questionnaire_id from assignment_questionnaires table
  # otherwise this assignment does not use the "varying rubrics", so in assignment_questionnaires table there should
  # be only 1 questionnaire with type 'ReviewQuestionnaire'.    -Yang
  def questionnaire(round = nil)
    Questionnaire.find_by(id: self.assignment.review_questionnaire_id(round))
  end

  def get_title
    "Review"
  end

  def delete(_force = nil)
    fmaps = FeedbackResponseMap.where(reviewed_object_id: self.response.response_id)
    fmaps.each(&:destroy)
    maps = MetareviewResponseMap.where(reviewed_object_id: self.id)
    maps.each(&:destroy)
    self.destroy
  end

  def self.export_fields(_options)
    ["contributor", "reviewed by"]
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

  def self.import(row_hash, _session, assignment_id)
    reviewee_team = Team.find_by(name: row_hash[:reviewee].to_s, parent_id: assignment_id)
    raise ArgumentError, "Could not find a team with name #{row_hash[:reviewee].to_s}, please import teams first" unless reviewee_team
    return unless reviewee_team
    row_hash[:reviewers].each do |reviewer|
      reviewer_user_name = reviewer.to_s
      reviewer_user = User.find_by(name: reviewer_user_name)
      raise ArgumentError, "Cannot find reviewer user." unless reviewer_user
      next if reviewer_user_name.empty?
      reviewer_participant = AssignmentParticipant.find_by(user_id: reviewer_user.id, parent_id: assignment_id)
      raise ArgumentError, "Reviewer user is not a participant in this assignment." unless reviewer_participant
      ReviewResponseMap.find_or_create_by(reviewed_object_id: assignment_id,
                                          reviewer_id: reviewer_participant.id,
                                          reviewee_id: reviewee_team.id,
                                          calibrate_to: false)
    end
  end

  def show_feedback(response)
    return unless self.response.any? and response
    map = FeedbackResponseMap.find_by(reviewed_object_id: response.id)
    return map.response.last.display_as_html if map and map.response.any?
  end

  def metareview_response_maps
    responses = Response.where(map_id: self.id)
    metareview_list = []
    responses.each do |response|
      metareview_response_maps = MetareviewResponseMap.where(reviewed_object_id: response.id)
      metareview_response_maps.each {|metareview_response_map| metareview_list << metareview_response_map }
    end
    metareview_list
  end

  # return the responses for specified round, for varying rubric feature -Yang
  def self.get_responses_for_team_round(team, round)
    responses = []
    if team.id
      maps = ResponseMap.where(reviewee_id: team.id, type: "ReviewResponseMap")
      maps.each do |map|
        if map.response.any? and map.response.reject {|r| (r.round != round || !r.is_submitted) }.any?
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
        ResponseMap.select("DISTINCT reviewer_id").where('reviewed_object_id = ? and type = ? and calibrate_to = ?', id, type, 0)
      @reviewers = []
      response_maps_with_distinct_participant_id.each do |reviewer_id_from_response_map|
        @reviewers << AssignmentParticipant.find(reviewer_id_from_response_map.reviewer_id)
      end
      @reviewers = Participant.sort_by_name(@reviewers)
    else
      # This is a search, so find reviewers by user's full name
      user_ids = User.select("DISTINCT id").where('fullname LIKE ?', '%' + review_user[:fullname] + '%')
      @reviewers = AssignmentParticipant.where('user_id IN (?) and parent_id = ?', user_ids, assignment.id)
    end
    # @review_scores[reveiwer_id][reviewee_id] = score for assignments not using vary_rubric_by_rounds feature
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

  def self.prepare_final_review_versions(assignment, maps)
    review_final_versions = {}
    rounds_num = assignment.rounds_of_reviews
    if rounds_num and rounds_num > 1
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
      next if responses.empty?
      responses.each do |response|
        response_ids << response.id
      end
    end
    review_final_versions[symbol][:response_ids] = response_ids
  end

  def self.newreviewresp(old_assign, catt, dict, new_assign_id)
    @old_reviewrespmap = ReviewResponseMap.where(reviewed_object_id: old_assign.id, reviewee_id: catt)
    @find_newrespmap =  ReviewResponseMap.where(reviewed_object_id: new_assign_id, reviewee_id: dict[catt])
    oldreviewrespids = []
    newreviewrespids = []
    @old_reviewrespmap.each do |zatt|
      oldreviewrespids.append(zatt.id)
    end
    @find_newrespmap.each do |zatt|
      newreviewrespids.append(zatt.id)
    end
    dict1 = Hash[oldreviewrespids.zip newreviewrespids]
    dict1.each do |item, value|
      @oldresp = Response.where(map_id: item)
      @oldresp.each do |zatt|
        @newresp = Response.new
        @newresp.map_id = value
        @newresp.additional_comment = zatt.additional_comment
        @newresp.version_num = zatt.version_num
        @newresp.round = zatt.round
        @newresp.is_submitted = zatt.is_submitted
        @newresp.save
        @oldanswers = Answer.where(response_id:zatt.id)
        @oldanswers.each do |latt|
          @newanswer = Answer.new
          @newanswer.question_id = latt.question_id
          @newanswer.answer = latt.answer
          @newanswer.comments = latt.comments
          @newanswer.response_id = @newresp.id
          @newanswer.save
        end
      end
    end
  end
  
end
