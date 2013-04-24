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
  

end
