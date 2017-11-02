class GlobalSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  attr_accessible

  def post_initialization
    self.display_type = 'Global Survey'
  end
end
