class SupplementaryReviewQuestionnaire < ReviewQuestionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'SupplementaryReview'
  end

  def symbol
    "supplementary".to_sym
  end

end
