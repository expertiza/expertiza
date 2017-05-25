class AssignmentSurveyDeployment < SurveyDeployment
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'parent_id'

  def parent_name
    assignment.name
  end

  def response_maps
    AssignmentSurveyResponseMap.where(reviewee_id: id)
  end
end
