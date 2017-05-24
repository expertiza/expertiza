class AssignmentSurveyDeployment < SurveyDeployment
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'parent_id'

  def parent_name
    assignment.name
  end
end
