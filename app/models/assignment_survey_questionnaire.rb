class AssignmentSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  @print_name = 'Assignment Survey'

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Assignment Survey'
  end
end
