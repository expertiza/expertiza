class CourseEvaluationQuestionnaire < Questionnaire
  def after_initialize    
    self.display_type = 'Course Evaluation' 
  end  
end
