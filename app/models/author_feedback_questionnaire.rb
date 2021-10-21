class AuthorFeedbackQuestionnaire < Questionnaire
  @print_name = "Author Feedback Rubric"
  DISPLAY_TYPE = 'Author Feedback'.freeze

  class << self
    attr_reader :print_name
  end

  def symbol
    "feedback".to_sym
  end

  def get_assessments_for(participant)
    participant.feedback
  end
end
