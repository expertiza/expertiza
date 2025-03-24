class ReviewBid < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
  belongs_to :assignment, class_name: 'Assignment'

  class << self
    # method to get bidding data
    def bidding_data(assignment_id, reviewer_ids)
      bidding_data = { 'tid' => [], 'users' => {}, 'max_accepted_proposals' => nil }
      bidding_data['tid'] = SignUpTopic.where(assignment_id: assignment_id).ids
      bidding_data['max_accepted_proposals'] = Assignment.where(id: assignment_id).pluck(:num_reviews_allowed).first

      reviewer_ids.each do |reviewer_id|
        bidding_data['users'][reviewer_id] = reviewer_bidding_data(reviewer_id, assignment_id)
      end
      bidding_data
    end

    def assign_review_topics(assignment_id, reviewer_ids, matched_topics, _min_num_reviews = 2)
      ReviewResponseMap.where(reviewed_object_id: assignment_id)&.destroy_all
    
      reviewer_ids.each do |reviewer_id|
        topics_to_assign = matched_topics[reviewer_id.to_s] || []  # ✅ Ensure it's always an array
        Rails.logger.debug "Assigning topics to reviewer #{reviewer_id}: #{topics_to_assign.inspect}"
    
        topics_to_assign.each do |topic|
          assign_topic_to_reviewer(assignment_id, reviewer_id, topic)
        end
      end
    end
    
    # method to assign a single topic to a reviewer
    def assign_topic_to_reviewer(assignment_id, reviewer_id, topic)
      team_to_review = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
      Rails.logger.debug "team_to_review: #{team_to_review}"
      return [] if team_to_review.nil?

      ReviewResponseMap.create(
        reviewed_object_id: assignment_id,
        reviewer_id: reviewer_id,
        reviewee_id: team_to_review,
        type: 'ReviewResponseMap'
      )
    end

    # method for getting individual reviewer_ids bidding data
    def reviewer_bidding_data(reviewer_id, assignment_id)
      reviewer_user_id = find_reviewer_user_id(reviewer_id)
      self_topic = fetch_self_topic(assignment_id, reviewer_user_id)
      team_id = fetch_team_id(assignment_id, reviewer_user_id)
      bidding_data = { 'bids' => [], 'otid' => self_topic }
      return bidding_data unless team_id

      bids = fetch_team_bids(team_id)
      bidding_data['bids'] = bids.map { |bid| format_bid(bid) }
      bidding_data
    end

    def fallback_algorithm(assignment_id, reviewer_ids)
      Rails.logger.debug "Fallback algorithm triggered for assignment_id: #{assignment_id}"
      topics = SignUpTopic.where(assignment_id: assignment_id).pluck(:id)
      topic_queue = sorted_topic_queue(topics)
      assign_topics(assignment_id, reviewer_ids, topic_queue)
    end
    
    private

    def sorted_topic_queue(topics)
      topic_counts = SignedUpTeam.where(topic_id: topics).joins(:team)
        .joins("LEFT JOIN teams_users ON teams.id = teams_users.team_id")
        .group(:topic_id).count("teams_users.user_id")
      sorted_topics = topic_counts.sort_by { |_, count| -count }.map(&:first)
      sorted_topics
    end
    
    def assign_topics(assignment_id, reviewer_ids, topic_queue)
      matched_topics, topic_index = {}, 0
      reviewer_ids.each do |reviewer_id|
        assigned_topic = find_available_topic(assignment_id, reviewer_id, topic_queue, topic_index)
        matched_topics[reviewer_id.to_s] = assigned_topic ? [assigned_topic] : []
        topic_index += 1 if assigned_topic
      end
      Rails.logger.debug "Final matched topics after fallback: #{matched_topics.inspect}"
      matched_topics
    end
    
    def find_available_topic(assignment_id, reviewer_id, topic_queue, topic_index)
      self_topic = fetch_self_topic(assignment_id, reviewer_id)
      topic_queue.each { |topic_id| return topic_id if topic_id != self_topic }
      nil
    end

    def reviewer_team_id(reviewer_id)
      TeamsUser.where(user_id: AssignmentParticipant.find(reviewer_id).user_id).pluck(:team_id).first
    end

    def find_reviewer_user_id(reviewer_id)
      AssignmentParticipant.find(reviewer_id).user_id
    end

    def fetch_self_topic(assignment_id, reviewer_user_id)
      SignedUpTeam.topic_id(assignment_id, reviewer_user_id)
    end

    def fetch_team_id(assignment_id, reviewer_user_id)
      TeamsUser.team_id(assignment_id, reviewer_user_id)
    end

    def fetch_team_bids(team_id)
      Bid.where(team_id: team_id)
    end

    def format_bid(bid)
      {
        'tid' => bid.topic_id,
        'priority' => bid.priority,
        'timestamp' => bid.updated_at.strftime('%a, %d %b %Y %H:%M:%S %Z %:z')
      }
    end
  end
end
