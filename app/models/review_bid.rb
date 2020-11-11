class ReviewBid < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
  belongs_to :assignment, class_name: 'Assignment'



  # method that returns the bidding data needed for the assigning algorithm
  # student_ids, topic_ids, student_preferences, topic_preferences
  def get_bidding_data(assignment_id,reviewers)
    bidding_data = Hash.new()
    for reviewer in reviewers do
      bidding_data[reviewer] = reviewer_bidding_data(reviewer,assignment_id)
    end
    return bidding_data
  end

  # list of reviewers from a specific assignment
  def reviewers(assignment_id)
	#list of reviewers for an assignment only if they have a topic from that assignment
	reviewers = AssignmentParticipants.find_by(parent_id: assignment_id, topic_id: !nil) #not sure this works lol
  end

  # assigns topics to reviews as matched by the webservice algorithm
  def assign_review_topics(assignment_id,reviewers,matched_topics)
  end 

end

def self.reviewer_bidding_data(reviewer,assignment_id)
    #has of bidding data for particular reviewers
      self_topic = reviewer_self_topic(reviewer,assignment_id)
      bidding_data = {'priority' => [], 'time' => [], 'tid' =>  [], 'otid' => self_topic}
      bids = ReviewBid.where(participant_id: reviewer)
      for bid in bids do
        bidding_data['priority'] << bid.priority
        bidding_data['time'] << bid.updated_at
        bidding_data['tid'] << bid.signuptopic_id
      end
      return bidding_data
    end