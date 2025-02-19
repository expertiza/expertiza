class GlobalSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  @print_name = 'Global Survey'

  class << self
    attr_reader :print_name
  end

  def post_initialization
    self.display_type = 'Global Survey'
  end
end
