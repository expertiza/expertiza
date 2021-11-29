class ReviewBid < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
  belongs_to :assignment, class_name: 'Assignment'


  # method to get bidding data 
  # returns the bidding data needed for the assigning algorithm
  # student_ids, topic_ids, student_preferences, topic_preferences, max reviews allowed
  public 
    def self.get_bidding_data(assignment_id,reviewers)
      # create basic hash and set basic hash data
      bidding_data = {'tid'=> [], 'users' => Hash.new, 'max_accepted_proposals' => []}
      bidding_data['tid'] = SignUpTopic.where(assignment_id: assignment_id).ids
      bidding_data['max_accepted_proposals'] = Assignment.where(id:assignment_id).pluck(:num_reviews_allowed).first

      # loop through reviewers to get reviewer specific bidding data
      for reviewer in reviewers do
        bidding_data['users'][reviewer] = self.reviewer_bidding_data(reviewer,assignment_id)
      end

      return bidding_data
    end

    # assigns topics to reviews as matched by the webservice algorithm
    def self.assign_review_topics(assignment_id,reviewers,matched_topics,min_num_reviews=2)
      # if review response map already created, delete it 
      if ReviewResponseMap.where(:reviewed_object_id => assignment_id)
        ReviewResponseMap.where(:reviewed_object_id => assignment_id).destroy_all
      end
      # loop through reviewers to assign reviews to each reviewer
      reviewers.each do |reviewer|
        topics_to_assign = matched_topics[reviewer.to_s]
        topics_to_assign.each do |topic|
          assign_topic_to_reviewer(assignment_id,reviewer,topic)
        end
      end
    end 

    # method to assign a single topic to a reviewer
    def self.assign_topic_to_reviewer(assignment_id,reviewer,topic)
      team_to_review = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
      team_to_review.nil? ? [] : ReviewResponseMap.create({:reviewed_object_id => assignment_id, :reviewer_id => reviewer, :reviewee_id => team_to_review, :type => "ReviewResponseMap"})
    end

    # method for getting individual reviewers bidding data
    # returns user's bidding data hash
    def self.reviewer_bidding_data(reviewer,assignment_id)
      # self_topic = self.reviewer_self_topic(reviewer)
      self_topic = SignedUpTeam.topic_id(reviewer.parent_id, reviewer.user_id)
      bidding_data = {'tid'=> [], 'otid' => self_topic, 'priority' => [], 'time'=>[]}
      bids = ReviewBid.where(participant_id: reviewer)

      # loop through each bid for a topic to get specific data
      for bid in bids do
        bidding_data['tid'] << bid.signuptopic_id
        bidding_data['priority'] << bid.priority
        bidding_data['time'] << bid.updated_at
      end

      return bidding_data
    end

end

