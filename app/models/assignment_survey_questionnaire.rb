class AssignmentSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  attr_accessible
  def post_initialization
    self.display_type = 'Assignment Survey'
  end
end
