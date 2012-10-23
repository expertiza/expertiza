class AuthorFeedbackQuestionnaire < Questionnaire
  def after_initialize    
    self.display_type = 'Author Feedback' 
  end
  
  def symbol
    return "feedback".to_sym
  end  
  
  def get_assessments_for(participant)
    participant.get_feedback()  
  end

  def get_weighted_score(assignment, scores)
    return compute_weighted_score(self.symbol, assignment, scores)
  end
end
