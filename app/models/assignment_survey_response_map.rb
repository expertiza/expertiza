class AssignmentSurveyResponseMap < SurveyResponseMap
  belongs_to :survey_deployment, class_name: 'SurveyDeployment', foreign_key: 'reviewee_id'
  belongs_to :assignment, class_name: 'Assignment', foreign_key: 'reviewed_object_id'
  belongs_to :reviewer, class_name: 'Participant', foreign_key: 'reviewer_id'

  def questionnaire
    Questionnaire.find_by(id: self.survey_deployment.questionnaire_id)
  end

  def contributor
    nil
  end

  def survey_parent
    self.assignment
  end

  def get_title
    "Assignment Survey"
  end
end
