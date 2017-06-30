class AssignmentSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Assignment Survey'
  end
end
