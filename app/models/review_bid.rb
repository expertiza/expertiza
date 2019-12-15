class ReviewBid < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'

  def get_quartiles(topic_id)
  	assignment_id = SignUpTopic.where(id: topic_id).pluck(:assignment_id).first
  	num_reviews_allowed = Assignment.where(id: assignment_id).pluck(:num_reviews_allowed).first
  	num_participants_in_assignment = AssignmentParticipant.where(parent_id: assignment_id).length
  	num_topics_in_assignment = SignUpTopic.where(assignment_id: assignment_id).length
  	num_choosers_this_topic = ReviewBid.where(sign_up_topic_id: topic_id).length
  	avg_reviews_per_topic = (num_participants_in_assignment*num_reviews_allowed)/num_topics_in_assignment

  	if num_choosers_this_topic < avg_reviews_per_topic/3:
  		return 'green'
  	elsif num_choosers_this_topic > avg_reviews_per_topic/3 and num_choosers_this_topic < avg_reviews_per_topic/3:
  		return 'yellow'
  	else :
  		return 'red'
  end
end
