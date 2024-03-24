class AuthorFeedbackQuestionnaire < Questionnaire
  after_initialize :post_initialization
  @print_name = 'Author Feedback Rubric'

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Author Feedback'
  end

  def symbol
    'feedback'.to_sym
  end

  def get_assessments_for(participant)
    participant.feedback
  end
end
