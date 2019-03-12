# E1600
# A new type called SelfReviewResponseMap was created for ResponseMap to handle self-reviews independent
##############################################################################
# E1920
# Fix Code Climate issues
#
# Code Climate mistakenly reports
# "Mass assignment is not restricted using attr_accessible"
# https://github.com/presidentbeef/brakeman/issues/579
#
class SelfReviewResponseMap < ResponseMap
  belongs_to :reviewee, inverse_of: :response_maps, class_name: 'Team', foreign_key: 'reviewee_id'
  belongs_to :assignment, inverse_of: :response_maps, class_name: 'Assignment', foreign_key: 'reviewed_object_id'

  # This method is used to get questionnaire for self-review to be performed by user
  def questionnaire(round)
    if self.assignment.varying_rubrics_by_round?
      Questionnaire.find(self.assignment.review_questionnaire_id(round))
    else
      Questionnaire.find(self.assignment.review_questionnaire_id)
    end
  end

  # This method helps to find contributor - here Team ID
  def contributor
    Team.find_by(id: self.reviewee_id)
  end

  # This method returns 'Title' of type of review (used to manipulate headings accordingly)
  # Change from get_title to title per Code Climate
  def title
    "Self Review"
  end

  # do not send any reminder for self review received.
  def email(defn, participant, assignment); end
end
