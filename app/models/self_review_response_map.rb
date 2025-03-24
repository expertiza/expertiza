# E1600
# A new type called SelfReviewResponseMap was created for ResponseMap to handle self-reviews independent
class SelfReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Team', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'
  belongs_to :reviewer, class_name: 'Participant', foreign_key: 'reviewer_id'

  # Find a review questionnaire associated with this self-review response map's assignment
  def questionnaire(round_number = nil, topic_id = nil)
    Questionnaire.find(assignment.review_questionnaire_id(round_number, topic_id))
  end

  # This method helps to find contributor - here Team ID
  def contributor
    Team.find_by(id: reviewee_id)
  end

  # This method returns 'Title' of type of review (used to manipulate headings accordingly)
  def get_title
    'Self Review'
  end

  # do not send any reminder for self review received.
  def email(defn, participant, assignment); end

  # Creates a self review mapping if one doesn't already exist
  def self.create_self_review(team_id, reviewer_id, assignment_id)
    if where(reviewee_id: team_id, reviewer_id: reviewer_id).exists?
      raise 'Self review already assigned!'
    end
    
    create(
      reviewee_id: team_id,
      reviewer_id: reviewer_id,
      reviewed_object_id: assignment_id
    )
  end
end
