class ParticipantReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id'

  def self.assign_reviewer submission_id, assignment_id, reviewer_id
     contributor = AssignmentParticipant.find_by_id_and_parent_id(submission_id, assignment_id)
      if ParticipantReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',contributor.id ,reviewer_id]).nil?
        ParticipantReviewResponseMap.create(:reviewee_id => contributor.id,
                                            :reviewer_id => reviewer_id,
                                            :reviewed_object_id => assignment_id)
      else
        flash[:error] = "There are no more submissions for you to review at this time."
        raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
      end
  end
end