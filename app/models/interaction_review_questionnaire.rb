class InteractionReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Interaction Review'
  end

  def symbol
    return "interaction".to_sym
  end

end