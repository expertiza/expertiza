class TeammateReviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  @print_name = 'Team Review Rubric'

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Teammate Review'
  end

  def symbol
    'teammate'.to_sym
  end

  def get_assessments_for(participant)
    participant.teammate_reviews
  end
end
