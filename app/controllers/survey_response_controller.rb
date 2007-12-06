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
      @assigned_surveys = SurveyHelper::get_all_available_surveys(@assignment.id)
      @survey = Questionnaire.find(params[:survey_id])
    
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
    @survey = Questionnaire.find(@survey_id)
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
    
    @surveys = SurveyHelper::get_all_available_surveys(@assignment_id)
  end
  
  def view_responses
    @assignment = Assignment.find(params[:id])
    if session[:user].role_id == 3 || session[:user].role_id == 4 
      @surveys = SurveyHelper::get_all_available_surveys(params[:id])
    else
      @surveys = SurveyHelper::get_assigned_surveys(params[:id])
    end
    @responses = Array.new
    @empty = true
    for survey in @surveys
      min = survey.min_question_score
      max = survey.max_question_score
      this_response_survey = Hash.new
      this_response_survey[:name] = survey.name
      this_response_survey[:id] = survey.id
      this_response_survey[:questions] = Array.new
      this_response_survey[:empty] = true
      surveylist = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ?", params[:id], survey.id]) 
      if surveylist.length > 0
        @empty = false
        this_response_survey[:empty] = false 
      end
      for question in survey.questions
        this_response_question = Hash.new
        this_response_question[:name] = question.txt
        this_response_question[:id] = question.id
        this_response_question[:scores] = Array.new
        this_response_question[:empty] = true
        for i in min..max
          list = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ? and question_id = ? and score = ?", params[:id], survey.id, question.id, i])
          this_score = Hash.new
          this_score[:value] = i
          this_score[:length] = list.length
          this_score[:empty] = true
          if list.length > 0 
            @empty = false
            this_response_survey[:empty] = false
            this_response_question[:empty] = false
          end
          this_response_question[:scores] << this_score
        end
        this_response_survey[:questions] << this_response_question
      end
      @responses << this_response_survey
    end
  end
  
  def comments
    @responses = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ? and question_id = ? and comments != ?", params[:assignment_id], params[:survey_id], params[:question_id], ""], :order => "score");
    @question = Question.find(params[:question_id])
    @survey = Questionnaire.find(params[:survey_id])
    @assignment = Assignment.find(params[:assignment_id])
  end
end
