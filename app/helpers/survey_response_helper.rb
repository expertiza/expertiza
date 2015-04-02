module SurveyResponseHelper

  def self.persist_survey(survey_id, question_id, assignment_id, survey_deployment_id, email_id)

    @new = SurveyResponse.new
    @new.survey_id = survey_id
    @new.question_id = question_id
    @new.assignment_id = assignment_id
    @new.survey_deployment_id=survey_deployment_id
    @new.email = email_id
  #  @new.score = @scores[question.id.to_s]
  #  @new.comments = @comments[question.id.to_s]
  #  @new.save

  end

end
