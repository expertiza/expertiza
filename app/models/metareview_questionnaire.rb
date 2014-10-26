class MetareviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Metareview'
  end

  def symbol
    return "metareview".to_sym
  end

  def get_assessments_for(participant)
    participant.metareviews()
  end


end
