class CourseEvaluationQuestionnaire < Questionnaire
  after_initialize :post_initialization
  def post_initialization
    self.display_type = 'Course Evaluation'
  end
end
