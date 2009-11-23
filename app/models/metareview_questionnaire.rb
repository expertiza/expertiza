class MetareviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Metareview' 
  end  
end
