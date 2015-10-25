class AuthorFeedbackQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Author Feedback'
  end

  def symbol
    return "feedback".to_sym
  end

  def get_assessments_for(participant)
    participant.feedback()
  end


end
