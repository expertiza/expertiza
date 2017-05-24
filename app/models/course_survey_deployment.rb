class CourseSurveyDeployment < SurveyDeployment
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'

  def parent_name
    course.name
  end
end
