class CourseSurveyDeployment < SurveyDeployment
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'

  def parent_name
    course.name
  end

  def response_maps
    CourseSurveyResponseMap.where(reviewee_id: id)
  end
end
