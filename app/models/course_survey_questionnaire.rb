class CourseSurveyQuestionnaire < SurveyQuestionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Course Survey'
  end
end
