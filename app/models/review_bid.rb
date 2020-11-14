class ReviewBid < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
  belongs_to :assignment, class_name: 'Assignment'



  # method that returns the bidding data needed for the assigning algorithm
  # student_ids, topic_ids, student_preferences, topic_preferences
  public 
  def self.get_bidding_data(assignment_id,reviewers)
    reviewers = self.reviewers(assignment_id) #repetivtive as we pass in the reviewers
    bidding_data = {'tid'=> [], 'users' => Hash.new, 'max_accepted_proposals' => []}
    bidding_data['tid'] = SignUpTopic.where(assignment_id: assignment_id).ids
    bidding_data['max_accepted_proposals'] = Assignment.where(id:assignment_id).pluck(:num_reviews_allowed).first
    for reviewer in reviewers do
      bidding_data['users'][reviewer] = self.reviewer_bidding_data(reviewer,assignment_id)
    end
    puts("Bidding Data:", bidding_data) #TODO remove this before deploying
    return bidding_data
  end

  # list of reviewers from a specific assignment
  #dont need a method for a oneliner?
  def self.reviewers(assignment_id)
	  reviewers = AssignmentParticipant.where(parent_id: assignment_id).ids
  end

  # assigns topics to reviews as matched by the webservice algorithm
  def self.assign_review_topics(assignment_id,reviewers,matched_topics,min_num_reviews=2)
    reviewers.each do |reviewer|
      topics_to_assign = matched_topics[reviewer.to_s]
      (1..min_num_reviews).each do |i|
        assign_topic_to_reviewer(assignment_id,reviewer,topics_to_assign[i])
      end
    end
  end 

  #method to assign a single topic to a reviewer
  def self.assign_topic_to_reviewer(assignment_id,reviewer,topic)
    team_to_review = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
    team_to_review.nil? ? [] : ReviewResponseMap.create({:reviewed_object_id => assignment_id, :reviewer_id => reviewer, :reviewee_id => team_to_review, :type => "ReviewResponseMap"})
  end


  #need this but hate that it has its own method
  def self.reviewer_self_topic(reviewer_id)
    participant = AssignmentParticipant.find_by(id: reviewer_id)
    team_id = participant.team.try(:id)
    self_topic = SignedUpTeam.where(team_id: team_id).pluck(:topic_id).first

    return self_topic
  end

  public
    def self.reviewer_bidding_data(reviewer,assignment_id)
      self_topic = self.reviewer_self_topic(reviewer)
      bidding_data = {'tid'=> [], 'otid' => self_topic, 'priority' => [], 'time'=>[]}
      bids = ReviewBid.where(participant_id: reviewer)
      for bid in bids do
        bidding_data['tid'] << bid.signuptopic_id
        bidding_data['priority'] << bid.priority
        bidding_data['time'] << bid.updated_at
      end
      return bidding_data
    end

end

