class SurveyResponseController < ApplicationController

  def create
    AuthController.clear_user_info(session)
    @survey = Rubric.find(params[:survey_id])
    @questions = @survey.questions
  end

  def submit
    @submitted = true;
    @survey_id = params[:survey_id]
    @survey = Rubric.find(@survey_id)
    @questions = @survey.questions
    @scores = params[:score]
    @comments = params[:comments]
    @assignment_id = params[:assignment_id]
    for question in @questions
      @new = SurveyResponse.new
      @new.survey_id = @survey_id
      @new.question_id = question.id
      @new.assignment_id = @assignment_id
      @new.email = params[:email]
      @new.score = @scores[question.id.to_s]
      @new.comments = @comments[question.id.to_s]
      @new.save
    end
    
    @surveys = SurveyHelper::get_assigned_surveys(@assignment_id)
  end

end
