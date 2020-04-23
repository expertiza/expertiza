class ReviewBid < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
  belongs_to :assignment, class_name: 'Assignment'

  def self.assignment_reviewers(assignment_id)
    #assignment id is the paramter to hold assignment id of reviewer.
    #function to get the participant id for all reviews with a topic given to them
    reviewers = AssignmentParticipant.where(parent_id: assignment_id).ids
    for reviewer in reviewers do
      if(reviewer_self_topic(reviewer,assignment_id)==nil)
        reviewers = reviewers - [reviewer]
      end
    end
    return reviewers
  end

  def self.assignment_bidding_data(assignment_id,reviewers)
  #hash of all the bidding data for an assignment
    bidding_data = Hash.new
    for reviewer in reviewers do
      bidding_data[reviewer] = reviewer_bidding_data(reviewer,assignment_id)
    end
    return bidding_data
  end

  def self.reviewer_bidding_data(reviewer,assignment_id)
  #has of bidding data for particular reviewers
    self_topic = reviewer_self_topic(reviewer,assignment_id)
    bidding_data = {'priority' => [], 'time' => [], 'tid' =>  [], 'otid' => self_topic}
    bids = ReviewBid.where(participant_id: reviewer)
    for bid in bids do
      bidding_data['priority'] << bid.priority
      # bidding_data['time'] << bid.updated_at
      bidding_data['time'] << 1
      #bidding_data['tid'] << bid.sign_up_topic_id
      bidding_data['tid'] << bid.topic_id
    end
    return bidding_data
  end

  def self.reviewer_self_topic(reviewer,assignment_id)
  #to return topic id  of the review a reviewer is working on
    user_id = Participant.where(id: reviewer).pluck(:user_id).first
    self_topic = ActiveRecord::Base.connection.execute("SELECT ST.topic_id FROM teams T, teams_users TU,signed_up_teams ST where TU.team_id=T.id and T.parent_id="+assignment_id.to_s+" and TU.user_id="+user_id.to_s+" and ST.team_id=TU.team_id;").first
    if self_topic==nil
      return self_topic
    end
    return self_topic.first
  end

  def self.assign_matched_topics(assignment_id,reviewers,matched_topics)
    for reviewer in reviewers do
      reviewer_matched_topics = matched_topics[reviewer.to_s]
      for topic in reviewer_matched_topics do
        # puts(topic)
        # puts(topic.class)
        matched_reviewee = SignedUpTeam.where(topic_id: topic).pluck(:team_id).first
        if(matched_reviewee != nil)
          ReviewResponseMap.create({:reviewed_object_id => assignment_id, :reviewer_id => reviewer, :reviewee_id => matched_reviewee, :type => "ReviewResponseMap"})
        end
      end
    end
  end
end 