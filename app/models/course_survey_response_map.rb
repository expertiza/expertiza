class CourseSurveyResponseMap < SurveyResponseMap
  belongs_to :survey_deployment, foreign_key: 'reviewee_id'
  belongs_to :course, foreign_key: 'reviewed_object_id'
  belongs_to :reviewer, class_name: 'Participant', foreign_key: 'reviewer_id'

  def questionnaire
    Questionnaire.find_by(id: self.survey_deployment.questionnaire_id)
  end

  def contributor
    nil
  end

  def survey_parent
    self.course
  end

  def get_title
    "Course Survey"
  end
end
