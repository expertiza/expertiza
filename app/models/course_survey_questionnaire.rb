class CourseSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization

  @print_name = 'Course Survey'

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Course Survey'
  end
end
