class SurveyResponseController < ApplicationController

  def create
    unless session[:user]   #redirect to homepage if user not logged in
      redirect_to '/'
      return
    end
    
    begin
      unless session[:assignment_id]   #if the anonymous session has not been tied to an assignment
        @participants = Participant.find(:all, :conditions => ["user_id = ? and assignment_id = ?", session[:user].id, params[:assignment_id]])
        if @participants.length == 0   #make sure the user is a participant of the assignment
          AuthController.logout(session)  #otherwise kick them out for their tomfoolery!
          redirect_to '/'
          return
        end
        AuthController.clear_user_info(session, params[:assignment_id])        
      end
    
      @assignment = Assignment.find(params[:assignment_id])
      @assigned_surveys = SurveyHelper::get_assigned_surveys(@assignment.id)
      @survey = Rubric.find(params[:survey_id])
    
      unless @assigned_surveys.include? @survey
        AuthController.logout(session)
        redirect_to '/'
        return
      end
    
      @questions = @survey.questions
    rescue
      AuthController.logout(session)
      redirect_to '/'
      return
    end
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
