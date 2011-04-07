class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file
  
  def view
    @response = Response.find(params[:id])
    return unless current_user_id?(@response.map.reviewer.user_id)

    @map = @response.map
    get_content  
  end   
  
  def delete
    @response = Response.find(params[:id])
    map_id = @response.map.id
    @response.delete
    redirect_to :action => 'redirection', :id => map_id, :return => params[:return], :msg => "The response was deleted."
  end
  
  def edit
    @header = "Edit"
    @next_action = "update"
    
    @return = params[:return]
    @response = Response.find(params[:id]) 
    return unless current_user_id?(@response.map.reviewer.user_id)
    @modified_object = @response.id
    @map = @response.map           
    get_content    
    @review_scores = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_response_id_and_question_id(@response.id, question.id)
    }
    render :action => 'response'
  end  
  
  def update
    @response = Response.find(params[:id])
    @myid = @response.id
    msg = ""
    begin 
      @myid = @response.id
      @map = @response.map
      @response.update_attribute('additional_comment',params[:review][:comments])
      
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions

      params[:responses].each_pair do |k,v|
        score = Score.find_by_response_id_and_question_id(@response.id, questions[k.to_i].id)
        score.update_attribute('score',v[:score])
        score.update_attribute('comments',v[:comment])
      end    
    rescue
      msg = "Your response was not saved. Cause: "+ $!
    end

    begin
       ResponseHelper.compare_scores(@response, @questionnaire)
       ScoreCache.update_cache(@response.id)
    
      msg = "Your response was successfully saved."
    rescue
      msg = "An error occurred while saving the response: "+$!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg
  end  
  
  def new_feedback
    review = Response.find(params[:id])
    if review
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, review.map.assignment.id)
      map = FeedbackResponseMap.find_by_reviewed_object_id_and_reviewer_id(review.id, reviewer.id)
      if map.nil?
        map = FeedbackResponseMap.create(:reviewed_object_id => review.id, :reviewer_id => reviewer.id, :reviewee_id => review.map.reviewer.id)
      end
      redirect_to :action => 'new', :id => map.id, :return => "feedback"
    else
      redirect_to :back
    end
  end
  
  def new
    @header = "New"
    @next_action = "create"    
    @feedback = params[:feedback]
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @modified_object = @map.id
    get_content    
    render :action => 'response'
  end
  
  def create     
    @map = ResponseMap.find(params[:id])
    @res = 0
    msg = ""
    error_msg = ""
    begin      
      @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments])
      @res = @response.id
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions     
      params[:responses].each_pair do |k,v|
        score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
      end  
    rescue
      error_msg = "Your response was not saved. Cause: " + $!
    end
    
    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      ScoreCache.update_cache(@res)
      @map.save
      msg = "Your response was successfully saved."
    rescue
      @response.delete
      error_msg = "Your response was not saved. Cause: " + $!
    end
    redirect_to :controller => 'response', :action => 'saving', :id => @map.id, :return => params[:return], :msg => msg, :error_msg => error_msg
  end      
  
  def saving   
    @map = ResponseMap.find(params[:id])
    @return = params[:return]
    @map.notification_accepted = false;
    @map.save
    
    redirect_to :action => 'redirection', :id => @map.id, :return => params[:return], :msg => params[:msg], :error_msg => params[:error_msg]
  end
  
  def redirection
    flash[:error] = params[:error_msg] unless params[:error_msg].empty?
    flash[:note]  = params[:msg] unless params[:msg].empty?
    
    @map = ResponseMap.find(params[:id])
    if params[:return] == "feedback"
      redirect_to :controller => 'grades', :action => 'view_my_scores', :id => @map.reviewer.id
    elsif params[:return] == "teammate"
      redirect_to :controller => 'student_team', :action => 'view', :id => @map.reviewer.id
    elsif params[:return] == "instructor"
      redirect_to :controller => 'grades', :action => 'view', :id => @map.assignment.id
    else
      redirect_to :controller => 'student_review', :action => 'list', :id => @map.reviewer.id
    end 
  end
  
  private
    
  def get_content    
    @title = @map.get_title 
    @assignment = @map.assignment
    @participant = @map.reviewer
    @contributor = @map.contributor
    @questionnaire = @map.questionnaire
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score     
  end      
end
