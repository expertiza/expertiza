class TeammateReviewQuestionnaire < Questionnaire
  after_initialize { post_initialization('Teammate Review') }
  @print_name = 'Team Review Rubric'

  def symbol
    'teammate'.to_sym
  end

  def get_assessments_for(participant)
    participant.teammate_reviews
  end
end
