class SurveyQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Survey'
  end
end
