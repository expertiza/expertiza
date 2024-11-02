class BookmarkRatingQuestionnaire < Questionnaire
  after_initialize { post_initialization('Bookmark Rating') }
  @print_name = 'Bookmark Rating Rubric'

  def symbol
    super('bookmark')
  end

  def get_assessments_for(participant)
    super(participant, :bookmark_reviews)
  end

  class << self
    attr_reader :print_name
  end
end
