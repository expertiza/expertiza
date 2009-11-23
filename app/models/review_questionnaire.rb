class ReviewQuestionnaire < Questionnaire
  def after_initialize
    self.display_type = 'Review'   
  end  
end
