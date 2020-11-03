# E1600
# A new type called SelfReviewResponseMap was created for ResponseMap to handle self-reviews independent
class SelfReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Team', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  # Find a review questionnaire associated with this self-review response map's assignment
  def questionnaire(round_number = nil, topic_id = nil)
    Questionnaire.find(self.assignment.review_questionnaire_id(round_number, topic_id))
  end

  # This method helps to find contributor - here Team ID
  def contributor
    Team.find_by(id: self.reviewee_id)
  end

  # This method returns 'Title' of type of review (used to manipulate headings accordingly)
  def get_title
    "Self Review"
  end

  # do not send any reminder for self review received.
  def email(defn, participant, assignment); end

  #E-1973 - returns the reviewer of the response, either a participant or a team
  def get_reviewer
    return ReviewResponseMap.get_reviewer_with_id(assignment.id, self.reviewee_id)
  end

  # E-1973 - gets the reviewer of the response, given the assignment and the reviewer id
  # the assignment is used to determine if the reviewer is a participant or a team
  def self.get_reviewer_with_id(assignment_id, reviewer_id)
    assignment = Assignment.find(assignment_id)
    if assignment.reviewer_is_team
      return AssignmentTeam.find(reviewer_id)
    else
      return AssignmentParticipant.find(reviewer_id)
    end
  end
end
