class BookmarkRatingQuestionnaire < Questionnaire
  @print_name = "Bookmark Rating Rubric"
  DISPLAY_TYPE = 'Bookmark Rating'.freeze

  class << self
    attr_reader :print_name
  end

  def symbol
    "bookmark".to_sym
  end

  def get_assessments_for(participant)
    participant.bookmark_reviews
  end
end
