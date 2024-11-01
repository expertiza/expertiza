class ReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Team', foreign_key: 'reviewee_id', inverse_of: false
  belongs_to :contributor, class_name: 'Team', foreign_key: 'reviewee_id', inverse_of: false
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id', inverse_of: false

  # Added for E1973:
  # http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_Project_E1973._Team_Based_Reviewing
  def after_initialize
    # If an assignment supports team reviews, it is marked in each mapping
    assignment.team_reviewing_enabled
  end

  # Find a review questionnaire associated with this review response map's assignment
  def questionnaire(round_number = nil, topic_id = nil)
    Questionnaire.find(assignment.review_questionnaire_id(round_number, topic_id))
  end

  def get_title
    'Review'
  end

  def delete(_force = nil)
    fmaps = FeedbackResponseMap.where(reviewed_object_id: response.response_id)
    fmaps.each(&:destroy)
    maps = MetareviewResponseMap.where(reviewed_object_id: id)
    maps.each(&:destroy)
    destroy
  end

  def self.export_fields(_options)
    ['contributor', 'reviewed by']
  end

  def self.export(csv, parent_id, _options)
    mappings = where(reviewed_object_id: parent_id).to_a
    mappings.sort! { |a, b| a.reviewee.name <=> b.reviewee.name }
    mappings.each do |map|
      csv << [
        map.reviewee.name,
        map.reviewer.name
      ]
    end
  end

  def self.import(row_hash, _session, assignment_id)
    reviewee_user = User.find_by!(name: row_hash[:reviewee].to_s)
    reviewee_participant = AssignmentParticipant.find_by!(user_id: reviewee_user.id, parent_id: assignment_id)
    reviewee_team = AssignmentTeam.team(reviewee_participant) || create_team(assignment_id, reviewee_user)
    row_hash[:reviewers].each do |reviewer|
      reviewer_user = User.find_by!(name: reviewer.to_s)
      next if reviewer_user.name.empty?

      reviewer_participant = AssignmentParticipant.find_by!(user_id: reviewer_user.id, parent_id: assignment_id)
      ReviewResponseMap.find_or_create_by(reviewed_object_id: assignment_id,
                                          reviewer_id: reviewer_participant.get_reviewer.id,
                                          reviewee_id: reviewee_team.id,
                                          calibrate_to: false)
    end
  end

  def self.get_responses_for_team_round(team, round)
    responses = []
    if team.id
      maps = ResponseMap.where(reviewee_id: team.id, type: 'ReviewResponseMap')
      maps.each do |map|
        if map.response.any? && map.response.reject { |r| (r.round != round || !r.is_submitted) }.any?
          responses << map.response.reject { |r| (r.round != round || !r.is_submitted) }.last
        end
      end
      responses.sort! { |a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    responses
  end

  def self.final_versions_from_reviewer(assignment_id, reviewer_id)
    reviewer = ReviewResponseMap.get_reviewer_with_id(assignment_id, reviewer_id)
    maps = ReviewResponseMap.where(reviewer_id: reviewer_id)
    assignment = Assignment.find(reviewer.parent_id)
    prepare_final_review_versions(assignment, maps)
  end

  def self.review_response_report(id, assignment, type, review_user)
    if review_user.nil?
      response_maps_with_distinct_participant_id =
        ResponseMap.select('DISTINCT reviewer_id').where('reviewed_object_id = ? and type = ? and calibrate_to = ?', id, type, 0)
      @reviewers = if assignment.team_reviewing_enabled
                     Team.sort_by_name(response_maps_with_distinct_participant_id.pluck(:reviewer_id).map { |id| ReviewResponseMap.get_reviewer_with_id(assignment.id, id) })
                   else
                     Participant.sort_by_name(response_maps_with_distinct_participant_id.pluck(:reviewer_id).map { |id| ReviewResponseMap.get_reviewer_with_id(assignment.id, id) })
                   end
    else
      user_ids = User.select('DISTINCT id').where('fullname LIKE ?', '%' + review_user[:fullname] + '%')
      if assignment.team_reviewing_enabled
        reviewer_participants = AssignmentTeam.where('id IN (?) and parent_id = ?', user_ids, assignment.id)
        @reviewers = reviewer_participants.map(&:team).uniq
      else
        @reviewers = AssignmentParticipant.where('user_id IN (?) and parent_id = ?', user_ids, assignment.id)
      end
    end
  end

  def email(defn, _participant, assignment)
    defn[:body][:type] = 'Peer Review'
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
    if rounds_num && (rounds_num > 1)
      (1..rounds_num).each do |round|
        prepare_review_response(assignment, maps, review_final_versions, round)
      end
    elsif assignment.vary_by_topic?
      prepare_review_response_by_topic(assignment, maps, review_final_versions)
    else
      prepare_review_response(assignment, maps, review_final_versions, nil)
    end
    review_final_versions
  end

  def self.prepare_review_response(assignment, maps, review_final_versions, round)
    symbol = round.nil? ? :review : ('review round' + ' ' + round.to_s).to_sym
    review_final_versions[symbol] = {
      questionnaire_id: assignment.review_questionnaire_id(round),
      response_ids: maps.map { |map| Response.where(map_id: map.id, round: round).last&.id }.compact
    }
  end

  def self.prepare_review_response_by_topic(assignment, maps, review_final_versions)
    responses_by_questionnaire = Hash.new { |hash, key| hash[key] = [] }

    maps.each do |map|
      team = AssignmentTeam.find(map.reviewee_id)
      topic_id = SignedUpTeam.topic_id_by_team_id(team.id)
      questionnaire = AssignmentQuestionnaire.where(assignment_id: assignment.id, topic_id: topic_id).first
      questionnaire_id = questionnaire.questionnaire_id
      responses = Response.where(map_id: map.id, round: 1).last
      responses_by_questionnaire[questionnaire_id] << responses.id unless responses.nil?
    end

    responses_by_questionnaire.each_with_index do |(questionnaire_id, response_ids), index|
      symbol = "review for rubric #{index + 1}".to_sym
      review_final_versions[symbol] = {
        questionnaire_id: questionnaire_id,
        response_ids: response_ids
      }
    end
  end

  private

  def self.create_team(assignment_id, reviewee_user)
    reviewee_team = AssignmentTeam.create(name: 'Team' + '_' + rand(1000).to_s,
                                          parent_id: assignment_id, type: 'AssignmentTeam')
    TeamsUser.create(team_id: reviewee_team.id, user_id: reviewee_user.id)
    TeamNode.create(parent_id: assignment_id, node_object_id: reviewee_team.id)
    reviewee_team
  end
end
