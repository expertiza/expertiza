class CourseSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  attr_accessible

  def post_initialization
    self.display_type = 'Course Survey'
  end
end
