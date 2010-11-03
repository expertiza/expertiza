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
         

# def list
#   @suggestions = Suggestion.find_all_by_assignment_id(params[:id])
#   @assignment = Assignment.find(params[:id])
# end

 def list
#   @suggestions = Suggestion.find_all_by_assignment_id(params[:id])   #commented out rsjohns3
#   Set Default values for Sort_by variable and Sort_order
#   OSS project_Team1 (rsjohns3) CSC517 Fall 2010
#   Following code adds sort drop down box when admin's are viewing suggestions
     sort_var = 'title'
     sort_order = ' ASC'
     
      if (params[:suggestions] != nil)
        if (params[:suggestions][:sortvar] != nil and params[:suggestions][:sortvar] != 'blank')
            puts "Value of params[:suggestions][:sortvar] -> #{params[:suggestions][:sortvar]}... "
            sort_var = params[:suggestions][:sortvar]
        end
      end

      if (params[:suggestions] != nil)
        if (params[:suggestions][:sortorder] != nil and params[:suggestions][:sortorder] != 'blank')
            puts "Value of params[:suggestions][:sortorder] -> #{params[:suggestions][:sortorder]}... "
            sort_order = " " + params[:suggestions][:sortorder]
        end
      end    
    @suggestions = Suggestion.find(:all, 
                            :conditions => 'assignment_id = '+params[:id],
                            :order => sort_var + sort_order)
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
    @suggestion.createdDate = DateTime.now
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
    elsif !params[:defer_suggestion].nil?
      defer_suggestion
    end
  end
  
  def approve_suggestion
    puts "Now entering Suggestion Controller Method approve_suggestion...."
    @suggestion = Suggestion.find(params[:id])
    @signuptopic = SignUpTopic.new
    @signuptopic.topic_identifier = 'S' + @suggestion.id.to_s
    @signuptopic.topic_name = @suggestion.title
    @signuptopic.topic_description = @suggestion.description  # rsjohns3 csc517-601 OSS Project 1 10/21/2010
    @signuptopic.assignment_id = @suggestion.assignment_id
    @signuptopic.max_choosers = 3;
    puts "@signuptopic.topic_description = #{@signuptopic.topic_description}..."
    puts "@suggestion.description = #{@suggestion.description}..."    
    
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
  
  # Set suggestions status to future, to be added to a later
  # topic list
  def defer_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Future')
      flash[:notice] = 'Successfully deferred the suggestion'
    else
      flash[:error] = 'Error when deferring the suggestion'
    end
    redirect_to :action => 'show', :id => @suggestion
  end
  
  # Edit a suggestion, so that it is acceptable for approval
  def edit_suggestion
    @suggestion = Suggestion.find(params[:id])
    # if current user's unity ID is not the same as the suggestion's,
    # instructor or TA is logged in
    if @suggestion.unityID != session[:user].name
      if not @suggestion.unityID.nil? and not @suggestion.unityID.empty?
        user = User.find_by_name(@suggestion.unityID)
        @toemail = user.id
      else
        @toemail = nil
      end
      @editor = "instructor"
      @suggestion.status = 'Reviewed'
    # else the submitter is logged in
    else
      assnt = Assignment.find(@suggestion.assignment_id)
      course = Course.find(assnt.course_id)
      instructor = User.find(course.instructor_id)
      @toemail = instructor.id
      @editor = session[:user].name
      @suggestion.status = 'Resubmitted'
    end
    
    # edit the suggestion, send notification to student/instructor,
    # and add the edit to the suggestion log
    if @suggestion.update_attributes(params[:suggestion_edit])
      flash[:notice] = 'Successfully updated the suggestion'
      if not @toemail.nil?
        @suggestion.email(@toemail, @editor)
      end
      # OSS project_Team1 (jmfoste2) CSC517 Fall 2010
      # Add logging to suggestion
      log_suggestion 
    else
      flash[:error] = 'Error when updating the suggestion'
    end
    if @editor == "instructor"
      redirect_to :action => "show", :id => params[:id]
    else
      redirect_to :action => "view_comments", :id => @suggestion.assignment_id
    end
  end
  
  # view all comments on the suggestions submitted by logged in student
  # for the currently selected assignment
  def view_comments
    assignment = Assignment.find(params[:id])
    @suggestions = Suggestion.find(:all, :conditions =>
              "unityID = '#{session[:user].name}' and status not in ('Approved', 'Rejected') and assignment_id = #{params[:id]}")
  end
  
  # OSS project_Team1 (jmfoste2) CSC517 Fall 2010
  # Add logging functionality to suggestions to track change history
  def log_suggestion
    @log = SuggestionLog.new
    @log.suggestion_id = @suggestion.id
    @log.user_id = session[:user].id
    @log.save
  end
end
