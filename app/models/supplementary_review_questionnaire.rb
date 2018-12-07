# This is one type of Questionnaire and  as intuitively expected this model class
# derives from Questionnaire.
class SupplementaryReviewQuestionnaire < Questionnaire
  # Make me better.
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'SupplementaryReview'
  end
  def symbol
    "supplementary".to_sym
  end
end
