class BookmarkratingQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Bookmarkrating'
  end

  def symbol
    return "bookmarkrating".to_sym
  end

  def get_assessments_for(participant)
    time1 = Time.now
    puts "####################################     get_assessments_for Current Time1 : " + time1.inspect
    participant.get_bookmarkrating()
  end

  def get_weighted_score(assignment, scores)
    return compute_weighted_score(self.symbol, assignment, scores)
  end
end
