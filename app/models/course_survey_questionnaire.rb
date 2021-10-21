class CourseSurveyQuestionnaire < SurveyQuestionnaire
  @print_name = "Course Survey"
  DISPLAY_TYPE = 'Course Survey'.freeze

  class << self
    attr_reader :print_name
  end
end
