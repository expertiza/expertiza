class MetareviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Metareview' 
  end  
  
  def symbol
    return "metareview".to_sym
  end
  
  def get_assessments_for(participant)
    participant.get_metareviews()  
  end  
  
  def get_weighted_score(assignment, scores)
    return compute_weighted_score(self.symbol, assignment, scores)
  end 
end
