class TeammateReviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Teammate Review'
  end

  def symbol
    return "teammate".to_sym
  end

  def get_assessments_for(participant)
    participant.teammate_reviews()
  end


end
