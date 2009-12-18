class ParticipantReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
end