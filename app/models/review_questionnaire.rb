class ReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Review'   
  end  
  
  def symbol
    return "review".to_sym
  end
  
  def get_reviews_for(participant)
    participant.get_reviews()  
  end  
  

end
