class GlobalSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize { post_initialization('Global Survey') }
  @print_name = 'Global Survey'

  class << self
    attr_reader :print_name
  end
end
