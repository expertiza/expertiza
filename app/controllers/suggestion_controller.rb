class SuggestionController < ApplicationController
 
  def add_comment
       @suggestioncomment = SuggestionComment.new(params[:suggestion_comment])
       @suggestioncomment.suggestion_id=params[:id]
       @suggestioncomment.commenter= session[:user].name
		if  @suggestioncomment.save
      flash[:notice] = "Successfully added your comment"
    else
      flash[:error] = "Error while adding comment"
    end
    redirect_to :action => "show", :id => params[:id]
  end
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @suggestions = Suggestion.find_all_by_assignment_id(params[:id])
    @assignment = Assignment.find(params[:id])
  end

  def show
    @suggestion = Suggestion.find(params[:id])
  end

  def new
    @suggestion = Suggestion.new
    session[:assignment_id] = params[:id]   
  end

  def create    
    @suggestion = Suggestion.new(params[:suggestion])
    @suggestion.assignment_id = session[:assignment_id]
	  @suggestion.status = 'Initiated'
    if params[:suggestion_anonymous].nil?
      @suggestion.unityID = session[:user].name      
    else
      @suggestion.unityID = "";
    end
    
    if @suggestion.save
      render :action => 'confirm_save'
    else
      render :action => 'new'
    end
  end
  
  def confirm_save
    # Action to display successful creation of suggestion
  end
  
  def submit
    if !params[:add_comment].nil?
      add_comment
    elsif !params[:approve_suggestion].nil?
      approve_suggestion
    elsif !params[:reject_suggestion].nil?
      reject_suggestion
    elsif !params[:edit_suggestion].nil?
      edit_suggestion
    end
  end
  
  def approve_suggestion
    @suggestion = Suggestion.find(params[:id])
    @signuptopic = SignUpTopic.new
    @signuptopic.topic_identifier = 'S' + @suggestion.id.to_s
    @signuptopic.topic_name = @suggestion.title
    @signuptopic.assignment_id = @suggestion.assignment_id
    @signuptopic.max_choosers = 3;
    
    if @signuptopic.save && @suggestion.update_attribute('status', 'Approved')
      flash[:notice] = 'Successfully approved the suggestion.'
    else
      flash[:error] = 'Error when approving the suggestion.'
    end
    redirect_to :action => 'show', :id => @suggestion
  end
  
  def reject_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Rejected')
      flash[:notice] = 'Successfully rejected the suggestion'
    else
      flash[:error] = 'Error when rejecting the suggestion'
    end
    redirect_to :action => 'show', :id => @suggestion
  end
  
  def edit_suggestion
    @suggestion = Suggestion.find(params[:id])
    if @suggestion.unityID != session[:user].name
      if not @suggestion.unityID.nil? and not @suggestion.unityID.empty?
        user = User.find_by_name(@suggestion.unityID)
        @toemail = user.id
      else
        @toemail = nil
      end
      @editor = "instructor"
      @suggestion.status = 'Reviewed'
    else
      assnt = Assignment.find(@suggestion.assignment_id)
      course = Course.find(assnt.course_id)
      instructor = User.find(course.instructor_id)
      @toemail = instructor.id
      @editor = session[:user].name
      @suggestion.status = 'Resubmitted'
    end
    
    if @suggestion.update_attributes(params[:suggestion_edit])
      flash[:notice] = 'Successfully updated the suggestion'
      if not @toemail.nil?
        @suggestion.email(@toemail, @editor)
      end
      #call log function here
    else
      flash[:error] = 'Error when updating the suggestion'
    end
    if @editor == "instructor"
      redirect_to :action => "show", :id => params[:id]
    else
      redirect_to :action => "view_comments", :id => @suggestion.assignment_id
    end
  end
  
  def view_comments
    assignment = Assignment.find(params[:id])
    @suggestions = Suggestion.find(:all, :conditions =>
              "unityID = '#{session[:user].name}' and status not in ('Approved', 'Rejected') and assignment_id = #{params[:id]}")
  end
end
