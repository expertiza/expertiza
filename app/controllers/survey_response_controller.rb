class SurveyResponseController < ApplicationController

  def begin_survey
    unless session[:user] #redirect to homepage if user not logged in
      redirect_to '/'
      return
    end
    
    @participants = Participant.find(:all, :conditions => ["user_id = ? and assignment_id = ?", session[:user].id, params[:id]])
    if @participants.length == 0   #make sure the user is a participant of the assignment
      AuthController.logout(session)  #otherwise kick them out for their tomfoolery!
      redirect_to '/'
      return
    end
    AuthController.clear_user_info(session, params[:id]) #ties the session to an assignment
  end

  def create
    unless session[:user] && session[:assignment_id]  #redirect to homepage if user not logged in or session not tied to assignment 
      redirect_to '/'
      return
    end
    
    begin          
      @assignment = Assignment.find(params[:id])
      @assigned_surveys = SurveyHelper::get_all_available_surveys(@assignment.id, 1)
      
      if params[:submit]
        @submit_survey = Questionnaire.find(params[:survey_id])
        @submit_questions = @submit_survey.questions
        @scores = params[:score]
        @comments = params[:comments]
        for question in @submit_questions
          list = []
          list = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ? and question_id = ? and email = ?", params[:id], params[:survey_id], question.id, params[:email]]) if params[:email]
          if list.length > 0
            @new = list[0] 
          else 
            @new = SurveyResponse.new
          end
          @new.survey_id = params[:survey_id]
          @new.question_id = question.id
          @new.assignment_id = params[:id]
          @new.email = params[:email]
          @new.score = @scores[question.id.to_s]
          @new.comments = @comments[question.id.to_s]
          @new.save
        end
      end
      
      if params[:count].to_i == @assigned_surveys.length
        redirect_to(:action =>'submit')
        return
      end
      
      @survey = @assigned_surveys[params[:count].to_i]
      @questions = @survey.questions
    rescue
      AuthController.logout(session)
      redirect_to '/'
      return
    end
  end

  def submit
 
  end
  
  def view_responses
    @assignment = Assignment.find(params[:id])
    @surveys = SurveyHelper::get_all_available_surveys(params[:id], session[:user].role_id)
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
        this_response_question[:labels] = Array.new
        this_response_question[:values] = Array.new
        this_response_question[:count] = 0
        for i in min..max
          if !question.true_false? || i == min || i == max
            list = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ? and question_id = ? and score = ?", params[:id], survey.id, question.id, i])
            if question.true_false?
              if i == min
                this_response_question[:labels] << "False"
              else
                this_response_question[:labels] << "True"
              end
            else
              this_response_question[:labels] << i
            end
            this_response_question[:values] << list.length
            this_response_question[:count] += list.length
            if list.length > 0 
              @empty = false
              this_response_survey[:empty] = false
            end
          end
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
