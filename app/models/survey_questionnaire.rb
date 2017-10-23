class SurveyQuestionnaire < Questionnaire
  after_initialize :post_initialization

  attr_accessible
  def post_initialization
    self.display_type = 'Survey'
  end
end
