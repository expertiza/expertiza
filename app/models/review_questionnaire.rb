class ReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Review'   
  end  
  
  def symbol
    return "review".to_sym
  end
  
  def get_assessments_for(participant)
    participant.reviews()
  end  
  

end
