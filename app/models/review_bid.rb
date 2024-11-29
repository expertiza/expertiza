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
    return nil unless topic&.assignment_id
    SignedUpTeam.topic_id(topic.assignment_id, participant.user_id)
  end

  # Assign topics to reviews
  def assign_review_topics(matched_topics, min_reviews: 2)
    # error handling
    raise ArgumentError, "Matched topics must be a Hash" unless matched_topics.is_a?(Hash)

    # Clear existing response maps for this assignment
    ReviewResponseMap.where(reviewed_object_id: topic.assignment_id).destroy_all

    # Assign topics for each reviewer
    matched_topics.each do |reviewer_id, topics|
      Array(topics).each do |topic_id|
        assign_topic_to_reviewer(reviewer_id, topic_id)
      end
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
end
