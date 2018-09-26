class GlobalSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  @print_name = "Global Survey"

  def self.print_name
    @print_name
  end

  def post_initialization
    self.display_type = 'Global Survey'
  end
end
