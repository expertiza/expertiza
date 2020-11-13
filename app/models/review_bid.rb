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
  def assign_review_topics(assignment_id,reviewers,matched_topics)
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

