module GlobalSurveyMapHelper

  def self.get_assigned_global_surveys(course_id,survey_id)
    joiners = GlobalSurveyMap.where("courses_id = ? and surveys_id = ?", course_id,survey_id)
    assigned_surveys = []
    for joiner in joiners
      survey = Questionnaire.find(joiner.global_surveys_id)
      assigned_surveys << survey
    end
    assigned_surveys.sort{|a,b| a.name <=> b.name}
  end

end
