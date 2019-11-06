class BookmarkRatingQuestionnaire < Questionnaire
  after_initialize :post_initialization
  @print_name = "Bookmark Rating Rubric"

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Bookmark Rating'
  end

  def symbol
    "bookmark".to_sym
  end

  def get_assessments_for(participant)
    participant.bookmark_reviews
  end

  # method to check if a dropdown is used for rating bookmarks
  def self.has_dropdown?(topic)
    bookmark_rating_questionnaire = topic.assignment.questionnaires.where(type: 'BookmarkRatingQuestionnaire')
    if bookmark_rating_questionnaire[0].nil?
      true
    else
      false
    end
  end
end
