class BookmarkRatingQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Bookmark Rating'
  end

  def symbol
    return "bookmark".to_sym
  end

  def get_assessments_for(participant)
    participant.bookmark_reviews()
  end


end
