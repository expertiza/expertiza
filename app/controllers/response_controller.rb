class ResponseController < ApplicationController
  helper :wiki
  helper :submitted_content
  helper :file
  
  def view
    @response = Response.find(params[:id])
    @map = @response.map
    get_content  
  end   
  
  def edit    
    @header = "Edit"
    @next_action = "update"
    
    @return = params[:return]
    @response = Response.find(params[:id]) 
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
    begin 
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
      flash[:error] = "#{@map.get_title} was not saved."
    end

    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      flash[:note] = "#{@map.get_title} was successfully saved."
    rescue
      flash[:error] = "An error occurred while saving the response: "+$!
    end
    
    redirect
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
    begin      
      @response = Response.create(:map_id => @map.id, :additional_comment => params[:review][:comments])
      @questionnaire = @map.questionnaire
      questions = @questionnaire.questions     
      params[:responses].each_pair do |k,v|
        score = Score.create(:response_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
      end  
    rescue
      flash[:error] = "#{@map.get_title} was not saved. Cause: "+$!
    end
    
    begin
      ResponseHelper.compare_scores(@response, @questionnaire)
      flash[:note] = "#{@map.get_title} was successfully saved."
    rescue
      @response.delete
      flash[:error] = "#{@map.get_title} was not saved. Cause: "+$!
    end
    redirect
  end      
  
  private
  
  def redirect
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
  
  def get_content    
    @title = @map.get_title 
    @assignment = @map.assignment
    @participant = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id,@assignment.id)    
    @files = @participant.get_submitted_files()
    @questionnaire = @map.questionnaire
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score     
  end
end
