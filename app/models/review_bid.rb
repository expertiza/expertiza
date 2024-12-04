class ReviewBid < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'

  # method to get bidding data
  # returns the bidding data needed for the assigning algorithm
  # student_ids, topic_ids, student_preferences, topic_preferences, max reviews allowed

  # Instance method to get bidding data for this review bid
  def bidding_data
    {
      'tid' => topic_ids,
      'otid' => self_topic,
      'priority' => priorities,
      'time' => updated_times
    }
  end

  # bid object to limit db touches for similar data acquisitions
  def bids
    @bids ||= ReviewBid.where(participant_id: participant_id)
  end

  def topic_ids
    bids.pluck(:signuptopic_id)
  end

  def priorities
    bids.pluck(:priority)
  end

  def updated_times
    bids.pluck(:updated_at)
  end

  def self_topic
    return nil unless topic && topic.assignment_id

    SignedUpTeam.topic_id(topic.assignment_id, participant.user_id)
  end

  # Assign topics to reviews
  def assign_review_topics(matched_topics)
    validate_topics_and_assignment!(matched_topics)

    ReviewResponseMap.where(reviewed_object_id: topic.assignment_id).destroy_all

    matched_topics.each do |reviewer_id, topics|
      Array(topics).each { |topic_id| assign_topic_to_reviewer(reviewer_id, topic_id) }
    end
  end

  # Assign a single topic to a reviewer
  def assign_topic_to_reviewer(reviewer_id, topic_id)
    team_to_review = SignedUpTeam.where(topic_id: topic_id).pluck(:team_id).first
    return if team_to_review.nil?

    ReviewResponseMap.create(
      reviewed_object_id: topic.assignment_id,
      reviewer_id: reviewer_id,
      reviewee_id: team_to_review,
      type: 'ReviewResponseMap'
    )
    # error handling
  rescue StandardError => e
    Rails.logger.error("Failed to assign topic #{topic_id} to reviewer #{reviewer_id}: #{e.message}")
  end

  private

  def validate_topics_and_assignment!(matched_topics)
    raise ArgumentError, 'Topic or assignment is missing' if topic.nil? || topic.assignment_id.nil?
    raise ArgumentError, 'Matched topics must be a Hash' unless matched_topics.is_a?(Hash)
  end
end
