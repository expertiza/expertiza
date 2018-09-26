class MetareviewQuestionnaire < Questionnaire
  after_initialize :post_initialization
  @print_name = "Metareview Rubric"

  def self.print_name
    @print_name
  end

  def post_initialization
    self.display_type = 'Metareview'
  end

  def symbol
    "metareview".to_sym
  end

  def get_assessments_for(participant)
    participant.metareviews
  end
end
