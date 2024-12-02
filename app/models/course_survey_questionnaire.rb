class CourseSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize { post_initialization('Course Survey') }

  @print_name = 'Course Survey'

  class << self
    attr_reader :print_name
  end
end
