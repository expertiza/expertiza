# E1600
# A new type called SelfReviewResponseMap was created for ResponseMap to handle self-reviews independent
class SelfReviewResponseMap < ResponseMap
  belongs_to :reviewee, class_name: 'Team', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  # Find a review questionnaire associated with this self-review response map's assignment
  # For more details please see method description for assignment.review_questionnaire_id()
  def questionnaire(round_number = nil, topic_id = nil)
    # Override arguments if they are non-sensical
    unless self.assignment.varying_rubrics_by_round?
      round_number = nil
    end
    unless self.assignment.varying_rubrics_by_topic?
      topic_id = nil
    end
    # Use find_by() instead of find() in case the review questionnaire id is nil
    Questionnaire.find_by(id: self.assignment.review_questionnaire_id(round_number, topic_id))
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
end
