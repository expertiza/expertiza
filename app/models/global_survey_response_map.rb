class GlobalSurveyResponseMap < SurveyResponseMap
  belongs_to :survey_deployment, class_name: 'SurveyDeployment', foreign_key: 'reviewee_id'
  belongs_to :questionnaire, class_name: 'Questionnaire', foreign_key: 'reviewed_object_id'
  belongs_to :reviewer, class_name: 'Participant', foreign_key: 'reviewer_id'

  def questionnaire
    Questionnaire.find_by(id: reviewed_object_id)
  end

  def contributor
    nil
  end

  def survey_parent
    questionnaire
  end

  def get_title
    'Global Survey'
  end
end
