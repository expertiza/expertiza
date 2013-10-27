class TeammateReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Teammate Review' 
  end
  
  def symbol
    return "teammate".to_sym
  end  
  
  def get_assessments_for(participant)
    participant.teammate_reviews()
  end  
  

end
