class ReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Review'   
  end  
  
  def symbol
    return "review".to_sym
  end
  
  def get_assessments_for(participant)
    participant.get_reviews()  
  end  
  
  def get_weighted_score(assignment, scores)
    return compute_weighted_score(self.symbol, assignment, scores)
  end  
end
