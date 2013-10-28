class GlobalSurveyQuestionnaire < Questionnaire
  def after_initialize   
    self.display_type = 'Global Survey'
  end  
end
