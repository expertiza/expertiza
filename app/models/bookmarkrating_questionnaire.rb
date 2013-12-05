class BookmarkratingQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Bookmarkrating'
  end

  def symbol
    return "bookmarkrating".to_sym
  end

  def get_assessments_for(participant)
    participant.get_bookmarkrating()
  end

  def get_weighted_score(assignment, scores)
    return compute_weighted_score(self.symbol, assignment, scores)
  end
end