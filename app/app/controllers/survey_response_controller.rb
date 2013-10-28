class SurveyResponseController < ApplicationController

  def begin_survey
    unless session[:user] #redirect to homepage if user not logged in
      redirect_to '/'
      return
    end
    
    @participants = AssignmentParticipant.find(:all, :conditions => ["user_id = ? and parent_id = ?", session[:user].id, params[:id]])
    if @participants.length == 0   #make sure the user is a participant of the assignment
      redirect_to '/'
      return
    end
  end

  def create
    
    if params[:course_eval] #Check if its a course evaluation
       @assigned_surveys = Questionnaire.find_all(params[:id])
       @survey = Questionnaire.find(params[:questionnaire_id])
       @questions = @survey.questions
       @course_eval=params[:course_eval]   
       #@assigned_surveys = SurveyHelper::get_course_surveys(params[:course_id], 1)
       return
    end
    
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
      
#      if params[:count].to_i == @assigned_surveys.length
#        redirect_to(:action =>'submit', :survey_id=>params[:survey_id], :score=>@scores, :assignment_id=>params[:id])
#        return
#      end
      
      @survey = @assigned_surveys[params[:count].to_i]
      @questions = @survey.questions
    rescue
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
      @new.survey_deployment_id=params[:survey_deployment_id]
      @new.email = params[:email]
      @new.score = @scores[question.id.to_s]
      @new.comments = @comments[question.id.to_s]
      @new.save
      end
    
    if !params[:survey_deployment_id]
      @surveys = SurveyHelper::get_assigned_surveys(@assignment_id)
    end
  end
  
  def view_responses
   
    if params[:course_eval] # Check if this is a course evaluation
       survey_id=SurveyDeployment.find(params[:id]).course_evaluation_id
       @surveys = Questionnaire.find(:all, :conditions=>["id=?", survey_id])
       #Temprorary Assignment object
       @assignment=Assignment.new
       @assignment.name="Course Evaluation"
       @assignment.id=params[:id]
       @course_eval=params[:course_eval]
    else
      @assignment = Assignment.find(params[:id])
      @surveys = SurveyHelper::get_all_available_surveys(params[:id], session[:user].role_id)
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
      this_response_survey[:avg_labels] = Array.new
      this_response_survey[:avg_values] = Array.new
      this_response_survey[:max] = max
      if !params[:course_eval]
        surveylist = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ?", params[:id], survey.id])
      else
        surveylist = SurveyResponse.find(:all, :conditions => ["survey_deployment_id = ? and survey_id = ?", params[:id], survey.id])
      end
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
        this_response_question[:average] = 0
        for i in min..max
          if !question.true_false? || i == min || i == max
            if !params[:course_eval]
              list = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ? and question_id = ? and score = ?", params[:id], survey.id, question.id, i])
            elsif params[:course_eval]
              list = SurveyResponse.find(:all, :conditions => ["survey_deployment_id = ? and survey_id = ? and question_id = ? and score = ?", params[:id], survey.id, question.id, i]);
            end
            if question.true_false?
              if i == min
                this_response_question[:labels] << "False"
              else
                this_response_question[:labels] << "True"
              end
            else
              this_response_question[:labels] << i
            end
            this_response_question[:values] << list.length.to_s  
            this_response_question[:average] += i*list.length
          end    
        end
        if !params[:course_eval]
          no_of_question = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ? and question_id = ?", params[:id], survey.id, question.id])
        else
          no_of_question = SurveyResponse.find(:all, :conditions => ["survey_deployment_id = ? and survey_id = ? and question_id = ?", params[:id], survey.id, question.id])
        end  
        this_response_question[:count] = no_of_question.length
        
        if this_response_question[:count] > 0 
          @empty = false
          this_response_survey[:empty] = false
          this_response_question[:average] /= this_response_question[:count].to_f  
          this_response_survey[:avg_labels] << this_response_question[:name][0..50] 
          this_response_survey[:avg_values] << this_response_question[:average]
        end
        this_response_survey[:questions] << this_response_question
      end
      @responses << this_response_survey
    end
  end
  
  def comments
    unless params[:course_eval] # Check if survey is a course evaluation
      @responses = SurveyResponse.find(:all, :conditions => ["assignment_id = ? and survey_id = ? and question_id = ?", params[:assignment_id], params[:survey_id], params[:question_id]], :order => "score"); 
    else
      @responses = SurveyResponse.find(:all, :conditions => ["survey_deployment_id = ? and survey_id = ? and question_id = ?", params[:assignment_id], params[:survey_id], params[:question_id]], :order => "score");
      @course_eval="1"   
    end
    
    @question = Question.find(params[:question_id])
    @survey = Questionnaire.find(params[:survey_id])
   
   unless params[:course_eval] 
    @assignment = Assignment.find(params[:assignment_id])
   else
    @assignment=Assignment.new
    @assignment.name="Course Evaluation"
   end
   
  end
end
