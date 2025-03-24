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

    # assigns topics to reviews as matched by the webservice algorithm
    # def assign_review_topics(assignment_id, reviewer_ids, matched_topics, _min_num_reviews = 2)
    #   ReviewResponseMap.where(reviewed_object_id: assignment_id)&.destroy_all

    #   reviewer_ids.each do |reviewer_id|
    #     topics_to_assign = matched_topics[reviewer_id.to_s]
    #     topics_to_assign.each do |topic|
    #       assign_topic_to_reviewer(assignment_id, reviewer_id, topic)
    #     end
    #   end
    # end

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
    
      matched_topics = {}
    
      # Step 1: Get available topics
      topics = SignUpTopic.where(assignment_id: assignment_id).pluck(:id)
      Rails.logger.debug "Available topics: #{topics}"
    
      # Step 2: Get team sizes and sort by largest teams first
      teams = SignedUpTeam.where(topic_id: topics)
                    .joins(:team)  # Join the teams table
                    .joins("LEFT JOIN teams_users ON teams.id = teams_users.team_id")  # Join with teams_users
                    .group(:topic_id)
                    .count("teams_users.user_id")  # Count the number of users per topic

      # DEBUGGING - Print before sorting
      #puts "Before sorting: #{teams}"
    
      # Sort teams by size (Descending Order)
      sorted_teams = teams.sort_by { |_, count| -count }  
    
      # DEBUGGING - Print after sorting
      #puts "After sorting: #{sorted_teams}"
    
      Rails.logger.debug "Teams sorted by size: #{sorted_teams}"
    
      # Step 3: Create topic queue (largest teams first)
      topic_queue = sorted_teams.map(&:first)  # Extract topic IDs
      Rails.logger.debug "Topic queue (sorted by largest team first): #{topic_queue}"
    
      # Step 4: Assign topics in a round-robin manner
      topic_index = 0
      reviewer_ids.each do |reviewer_id|
        assigned_topic = nil
        self_topic = fetch_self_topic(assignment_id, reviewer_id)
    
        # Ensure reviewer does not get their own team's topic
        attempts = 0
        while assigned_topic.nil? && attempts < topic_queue.size
          topic_id = topic_queue[topic_index % topic_queue.size] # Round-robin selection
          unless topic_id == self_topic
            assigned_topic = topic_id
            Rails.logger.debug "Assigned topic #{assigned_topic} to reviewer #{reviewer_id}"
            topic_index += 1  # Move to next topic for next reviewer
          end
          attempts += 1
        end
    
        matched_topics[reviewer_id.to_s] = assigned_topic ? [assigned_topic] : []
      end
    
      Rails.logger.debug "Final matched topics after fallback: #{matched_topics.inspect}"
      matched_topics
    end

    private

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
