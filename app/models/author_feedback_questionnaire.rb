class AuthorFeedbackQuestionnaire < Questionnaire
  @print_name = 'Author Feedback Rubric'

  after_initialize { post_initialization('Author Feedback') }

  def symbol
    super('feedback')
  end

  def get_assessments_for(participant)
    super(participant, :feedback)
  end
end
