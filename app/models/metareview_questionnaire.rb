class MetareviewQuestionnaire < Questionnaire
  @print_name = "Metareview Rubric"
  DISPLAY_TYPE = 'Metareview'.freeze

  class << self
    attr_reader :print_name
  end

  def symbol
    "metareview".to_sym
  end

  def get_assessments_for(participant)
    participant.metareviews
  end
end
