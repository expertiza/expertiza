class ParticipantReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id'

  # Evaluates whether this participant contribution was reviewed by reviewer
  # @param[in] reviewer AssignmentParticipant object
  def reviewed_by?(reviewer)
    ParticipantReviewResponseMap.where(['reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', self.id, reviewer.id, assignment.id]).count > 0
  end

end
