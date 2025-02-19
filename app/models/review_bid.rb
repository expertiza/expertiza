class ReviewBid < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
  belongs_to :assignment, class_name: 'Assignment'

  # method to get bidding data
  # returns the bidding data needed for the assigning algorithm
  # student_ids, topic_ids, student_preferences, topic_preferences, max reviews allowed

  def self.bidding_data(assignment_id, reviewer_ids)
    # create basic hash and set basic hash data
    bidding_data = { 'tid' => [], 'users' => {}, 'max_accepted_proposals' => [] }
    bidding_data['tid'] = SignUpTopic.where(assignment_id: assignment_id).ids
    bidding_data['max_accepted_proposals'] = Assignment.where(id: assignment_id).pluck(:num_reviews_allowed).first

    # loop through reviewer_ids to get reviewer specific bidding data
    reviewer_ids.each do |reviewer_id|
      bidding_data['users'][reviewer_id] = reviewer_bidding_data(reviewer_id, assignment_id)
    end
    bidding_data
  end

  # assigns topics to reviews as matched by the webservice algorithm
  def self.assign_review_topics(assignment_id, reviewer_ids, matched_topics, _min_num_reviews = 2)
    # if review response map already created, delete it
    if ReviewResponseMap.where(reviewed_object_id: assignment_id)
      ReviewResponseMap.where(reviewed_object_id: assignment_id).destroy_all
    end
    # loop through reviewer_ids to assign reviews to each reviewer
    reviewer_ids.each do |reviewer_id|
      topics_to_assign = matched_topics[reviewer_id.to_s]
      topics_to_assign.each do |topic|
        assign_topic_to_reviewer(assignment_id, reviewer_id, topic)
      end
    end
  end

  # method to assign a single topic to a reviewer
  def self.assign_topic_to_reviewer(assignment_id, reviewer_id, topic)
    team_to_review = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
    team_to_review.nil? ? [] : ReviewResponseMap.create(reviewed_object_id: assignment_id, reviewer_id: reviewer_id, reviewee_id: team_to_review, type: 'ReviewResponseMap')
  end

  # method for getting individual reviewer_ids bidding data
  # returns user's bidding data hash
  def self.reviewer_bidding_data(reviewer_id, assignment_id)
    reviewer_user_id = AssignmentParticipant.find(reviewer_id).user_id
    self_topic = SignedUpTeam.topic_id(assignment_id, reviewer_user_id)
    bidding_data = { 'tid' => [], 'otid' => self_topic, 'priority' => [], 'time' => [] }
    bids = ReviewBid.where(participant_id: reviewer_id)

    # loop through each bid for a topic to get specific data
    bids.each do |bid|
      bidding_data['tid'] << bid.signuptopic_id
      bidding_data['priority'] << bid.priority
      bidding_data['time'] << bid.updated_at
    end
    bidding_data
  end
end
