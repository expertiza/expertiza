class GlobalSurveyQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Global Survey'
  end
end
