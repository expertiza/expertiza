class AssignmentSurveyQuestionnaire < SurveyQuestionnaire
  @print_name = "Assignment Survey"
  DISPLAY_TYPE = 'Assignment Survey'.freeze

  class << self
    attr_reader :print_name
  end
end
