class AuthorFeedbackQuestionnaire < Questionnaire
  def after_initialize    
    self.display_type = 'Author Feedback' 
  end
end
