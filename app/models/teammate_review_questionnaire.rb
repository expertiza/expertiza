class TeammateReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Teammate Review' 
  end
end
