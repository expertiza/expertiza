class ReviewBid < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
  belongs_to :assignment, class_name: 'Assignment'

  validates :signuptopic_id, presence: true
  validates :participant_id, numericality: { only_integer: true }
  # method to get bidding data
  # returns the bidding data needed for the assigning algorithm
  # student_ids, topic_ids, student_preferences, topic_preferences, max reviews allowed

  def bidding_data(assignment_id, reviewer_ids)
    # create basic hash and set basic hash data
    bid_data = { 'tid' => [], 'users' => {}, 'max_accepted_proposals' => [] }
    bid_data['tid'] = SignUpTopic.where(assignment_id: assignment_id).ids
    bid_data['max_accepted_proposals'] = Assignment.where(id: assignment_id).pluck(:num_reviews_allowed).first

    # loop through reviewer_ids to get reviewer specific bidding data
    reviewer_ids.each do |reviewer_id|
      bid_data['users'][reviewer_id] = reviewer_bidding_data(reviewer_id, assignment_id)
    end
    return [] if bid_data['tid'].nil?
    return [] if bid_data['max_accepted_proposals'].nil?
    bid_data
  end

  # assigns topics to reviews as matched by the webservice algorithm
  def assign_review_topics(assignment_id, reviewer_ids, matched_topics, _min_num_reviews = 2)
    ReviewResponseMap.where(reviewed_object_id: assignment_id).destroy_all

    reviewer_ids.each do |reviewer_id|
      topics_to_assign = matched_topics[reviewer_id.to_s] || []
      next if topics_to_assign.empty? # Skip if no topics to assign

      topics_to_assign.each do |topic|
        assign_topic_to_reviewer(assignment_id, reviewer_id, topic)
      end
    end
  end

  def assign_topic_to_reviewer(assignment_id, reviewer_id, topic)
    team_to_review = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
    return [] if team_to_review.nil?

    ReviewResponseMap.find_or_create_by(
      reviewed_object_id: assignment_id,
      reviewer_id: reviewer_id,
      reviewee_id: team_to_review
    ) { |map| map.type = 'ReviewResponseMap' }
  end

  # method for getting individual reviewer_ids bidding data
  # returns user's bidding data hash
  def reviewer_bidding_data(reviewer_id, assignment_id)
    reviewer_user_id = AssignmentParticipant.find(reviewer_id).user_id
    self_topic = SignedUpTeam.topic_id(assignment_id, reviewer_user_id)
    bid_data = { 'tid' => [], 'otid' => self_topic, 'priority' => [], 'time' => [] }
    bids = ReviewBid.where(participant_id: reviewer_id)

    # loop through each bid for a topic to get specific data
    bids.each do |bid|
      bid_data['tid'] << bid.signuptopic_id
      bid_data['priority'] << bid.priority
      bid_data['time'] << bid.updated_at
    end
    bid_data
  end
end
