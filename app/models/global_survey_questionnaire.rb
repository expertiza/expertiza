class GlobalSurveyQuestionnaire < SurveyQuestionnaire
  @print_name = "Global Survey"
  DISPLAY_TYPE = 'Global Survey'.freeze

  class << self
    attr_reader :print_name
  end

end
