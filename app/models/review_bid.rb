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
    def assign_review_topics(assignment_id, reviewer_ids, matched_topics, _min_num_reviews = 2)
      ReviewResponseMap.where(reviewed_object_id: assignment_id)&.destroy_all

      reviewer_ids.each do |reviewer_id|
        topics_to_assign = matched_topics[reviewer_id.to_s]
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

    private

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
