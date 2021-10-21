class TeammateReviewQuestionnaire < Questionnaire
  @print_name = "Team Review Rubric"
  DISPLAY_TYPE = 'Teammate Review'

  class << self
    attr_reader :print_name
  end


  def symbol
    "teammate".to_sym
  end

  def get_assessments_for(participant)
    participant.teammate_reviews
  end
end
