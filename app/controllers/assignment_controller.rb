class AssignmentController < ApplicationController
  require 'ftools'
  auto_complete_for :user, :name
  before_filter :authorize
  
  @no_dl="1" # a value of "no" for whether an action is permitted prior to a deadline
  @late_dl="2" # a value of "late" for whether an action is permitted prior to a deadline (it is permitted, but marked late)
  @ok_dl="3" # a value of "OK" for whether an action is permitted prior to a deadline
  
  
  def copy    
    old_assign = Assignment.find(params[:id])
    new_assign = old_assign.clone
    if (session[:user]).role_id != 6
      new_assign.instructor_id = session[:user].id
    else # for TA we need to get his instructor id and by default add it to his course for which he is the TA
      new_assign.instructor_id = Ta.get_my_instructor((session[:user]).id)
      new_assign.course_id = TaMapping.get_course_id((session[:user]).id)
    end 
    
    
    new_assign.name = 'Copy of '+new_assign.name 
    new_assign.created_at = new_assign.updated_at
    if new_assign.save    
      new_assign.created_at = new_assign.updated_at
      new_assign.save
      DueDate.copy(old_assign.id, new_assign.id)           
      new_assign.create_node()
      
      flash[:note] = 'The assignment is currently associated with an existing location. This could cause errors for furture submissions.'
      redirect_to :action => 'edit', :id => new_assign.id
    else
      flash[:error] = 'The assignment was not able to be copied. Please check the original assignment for missing information.'
      redirect_to :action => 'list', :controller => 'tree_display'
    end
  end  
  
  def new
    if params[:parent_id]
      @course = Course.find(params[:parent_id])           
    end    
    @assignment = Assignment.new
    @questionnaire = Questionnaire.find_all
    @wiki_types = WikiType.find_all
    @private = params[:private] == true        
    default = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',session[:user].id])
    @limits = Hash.new
    @limits = {:review => default.limit,
               :metareview => default.limit,
               :teammate => default.limit,
               :feedback => default.limit}
               
    @weights = Hash.new
    @weights = {:review => 100,
                :metareview => 0,
                :teammate => 0,
                :feedback => 0}               
  end
  
  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    assignment = Assignment.find(params[:id])
    assignment.private = !assignment.private
    assignment.save
    
    redirect_to :controller => 'tree_display', :action => 'list'
  end
  
  def create
    # The Assignment Directory field to be filled in is the path relative to the instructor's home directory (named after his user.name)
    # However, when an administrator creates an assignment, (s)he needs to preface the path with the user.name of the instructor whose assignment it is.    
    @assignment = Assignment.new(params[:assignment])    
    if (session[:user]).role_id != 6
      @assignment.instructor_id = (session[:user]).id
    else # for TA we need to get his instructor id and by default add it to his course for which he is the TA
      @assignment.instructor_id = Ta.get_my_instructor((session[:user]).id)
      @assignment.course_id = TaMapping.get_course_id((session[:user]).id)
    end  
    @assignment.submitter_count = 0    
    ## feedback added
    ##
    @duedate=DueDate.new
    
    # Deadline types used in the deadline_types DB table
    @Submission_deadline=1;
    @Review_deadline=2;
    @Resubmission_deadline=3;
    @Rereview_deadline=4;
    @Review_of_review_deadline=5;   
    
    if @assignment.save  
      set_limits
      set_weights
      submit_duedate=DueDate.new(params[:submit_deadline]);
      submit_duedate.deadline_type_id=@Submission_deadline;
      submit_duedate.assignment_id=@assignment.id;
      # ajbudlon 5/28/2008 commented out late policy
      #submit_duedate.late_policy_id=params[:for_due_date][:late_policy_id];      
      ## feedback added
      submit_duedate.round = 1;
      ##
      submit_duedate.save;
      
      review_duedate=DueDate.new(params[:review_deadline]);
      review_duedate.deadline_type_id=@Review_deadline;
      review_duedate.assignment_id=@assignment.id;
      # ajbudlon 5/28/2008 commented out late policy
      #review_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
      ## feedback added
      review_duedate.round = 1;
      ##
      review_duedate.save;
      ## feedback added
      max_round = 2;
      ##
      
      if params[:assignment_helper][:no_of_reviews].to_i >= 2
        for resubmit_duedate_key in params[:additional_submit_deadline].keys
          resubmit_duedate=DueDate.new(params[:additional_submit_deadline][resubmit_duedate_key]);
          resubmit_duedate.deadline_type_id=@Resubmission_deadline;
          resubmit_duedate.assignment_id=@assignment.id;
          # ajbudlon 5/28/2008 commented out late policy
          #resubmit_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
          ## feedback added
          resubmit_duedate.round = max_round
          max_round = max_round + 1
          ##
          resubmit_duedate.save;
        end
        ## feedback added
        max_round = 2
        ##
        for rereview_duedate_key in params[:additional_review_deadline].keys
          rereview_duedate=DueDate.new(params[:additional_review_deadline][rereview_duedate_key]);
          rereview_duedate.deadline_type_id=@Rereview_deadline;
          rereview_duedate.assignment_id=@assignment.id;
          # ajbudlon 5/28/2008 commented out late policy
          #rereview_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
          ## feedback added
          rereview_duedate.round = max_round
          max_round = max_round + 1
          ##
          rereview_duedate.save;
        end
        ## feedback added
       
        
      end      
      reviewofreview_duedate=DueDate.new(params[:reviewofreview_deadline]);
      reviewofreview_duedate.deadline_type_id=@Review_of_review_deadline;
      reviewofreview_duedate.assignment_id=@assignment.id;
      # ajbudlon 5/28/2008 commented out late policy
      #reviewofreview_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
      ## feedback added
      reviewofreview_duedate.round = max_round
      ##
      reviewofreview_duedate.save;        
            
      # Create submission directory for this assignment
      # If assignment is a Wiki Assignment (or has no directory)
      # the helper will not create a path
      FileHelper.create_directory(@assignment)      
      
      # Creating node information for assignment display
      @assignment.create_node()
       
      flash[:notice] = 'Assignment was successfully created.'
      redirect_to :action => 'list', :controller => 'tree_display'
      
    else
      @wiki_types = WikiType.find_all
      render :action => 'new'
    end
    
  end
    
  def edit
    @assignment = Assignment.find(params[:id])
    get_instructor_notification_limits
    get_weights
    @wiki_types = WikiType.find_all
  end
  
  def define_instructor_notification_limit(assignment_id, questionnaire_id, limit)
     existing = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id = ? and questionnaire_id = ?',session[:user].id,assignment_id,questionnaire_id])
     if existing.nil?
       NotificationLimit.create(:user_id => session[:user].id,
                                :assignment_id => assignment_id,
                                :questionnaire_id => questionnaire_id,
                                :limit => limit)
     else
        existing.limit = limit
        existing.save
     end    
  end
  
  def define_weight(assignment_id, questionnaire_id, type, weight)    
     existing = QuestionnaireWeight.find(:first, :conditions => ['assignment_id = ? and questionnaire_id = ?',assignment_id,questionnaire_id])
     if existing.nil?
       qw = QuestionnaireWeight.create(:assignment_id => assignment_id,
                                       :questionnaire_id => questionnaire_id,
                                       :weight => weight)                                      
       qw.type = type                                      
       qw.save                                
     else
        existing.weight = weight
        existing.save
     end    
  end  
  
  def set_limits
    if params[:limits]
        if @assignment.review_questionnaire_id and (params[:limits][:review] != params[:review_limit])          
          define_instructor_notification_limit(@assignment.id, @assignment.review_questionnaire_id, params[:limits][:review])                       
        end         
        if @assignment.review_of_review_questionnaire_id and (params[:limits][:metareview] != params[:metareview_limit])
          define_instructor_notification_limit(@assignment.id, @assignment.review_of_review_questionnaire_id, params[:limits][:metareview])                             
        end        
        if @assignment.teammate_review_questionnaire_id and (params[:limits][:teammate] != params[:teammate_limit])           
          define_instructor_notification_limit(@assignment.id, @assignment.teammate_review_questionnaire_id, params[:limits][:teammate])
        end
              
        if @assignment.author_feedback_questionnaire_id and (params[:limits][:feedback] != params[:feedback_limit])                      
          define_instructor_notification_limit(@assignment.id, @assignment.author_feedback_questionnaire_id, params[:limits][:feedback])
        end
      end    
  end  
  
  def set_weights
    if params[:weights]
        if @assignment.review_questionnaire_id          
          define_weight(@assignment.id, @assignment.review_questionnaire_id, "ReviewWeight", params[:weights][:review])                       
        end 
        
        if @assignment.review_of_review_questionnaire_id 
          define_weight(@assignment.id, @assignment.review_of_review_questionnaire_id, "MetareviewWeight", params[:weights][:metareview])                             
        end
        
        if @assignment.teammate_review_questionnaire_id 
          define_weight(@assignment.id, @assignment.teammate_review_questionnaire_id , "AuthorFeedbackWeight", params[:weights][:teammate])
        end
               
        if @assignment.author_feedback_questionnaire_id 
          define_weight(@assignment.id, @assignment.author_feedback_questionnaire_id, "TeammateReviewWeight", params[:weights][:feedback])
        end
      end    
  end    
  
  def get_instructor_notification_limits
    @limits = Hash.new
        
    default = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',session[:user].id])   
    
    #handle TAs
    if default == nil
      default = NotificationLimit.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@assignment.instructor_id])
    end

    review = NotificationLimit.find(:first, 
                                 :conditions => ['assignment_id = ? and questionnaire_id = ?',                                                
                                                 @assignment.id,
                                                 @assignment.review_questionnaire_id])
    if review != nil                                                 
       @limits[:review] = review.limit
    else
       @limits[:review] = default.limit
    end
    
    metareview = NotificationLimit.find(:first, 
                                 :conditions => ['assignment_id = ? and questionnaire_id = ?',
                                                 @assignment.id,
                                                 @assignment.review_of_review_questionnaire_id])
    if metareview != nil                                                 
       @limits[:metareview] = metareview.limit
    else
       @limits[:metareview] = default.limit
    end
    
    teammate = NotificationLimit.find(:first, 
                                 :conditions => ['assignment_id = ? and questionnaire_id = ?',
                                                 @assignment.id,
                                                 @assignment.teammate_review_questionnaire_id])
    if teammate != nil                                                 
       @limits[:teammate] = teammate.limit
    else
       @limits[:teammate] = default.limit
    end 
    
    feedback = NotificationLimit.find(:first, 
                                 :conditions => ['assignment_id = ? and questionnaire_id = ?',
                                                 @assignment.id,
                                                 @assignment.author_feedback_questionnaire_id])
    if feedback != nil                                                 
       @limits[:feedback] = feedback.limit
    else
       @limits[:feedback] = default.limit
    end              
  end
  
  def get_weights
    @weights = Hash.new
    review = ReviewWeight.find_by_assignment_id(@assignment.id)
    metareview = MetareviewWeight.find_by_assignment_id(@assignment.id)
    feedback = AuthorFeedbackWeight.find_by_assignment_id(@assignment.id)
    teammate = TeammateReviewWeight.find_by_assignment_id(@assignment.id)
    
    if review != nil
      @weights[:review] = review.weight
    else
      @weights[:review] = 100
    end
    
    if metareview != nil
      @weights[:metareview] = metareview.weight
    else
      @weights[:metareview] = 0
    end
    
    if feedback != nil
      @weights[:feedback] = feedback.weight
    else
      @weights[:feedback] = 0
    end
    
    if teammate != nil
      @weights[:teammate] = teammate.weight
    else
      @weights[:teammate] = 0
    end    
  end  
  
  def update  
    if params[:assignment][:course_id]
     begin
       Course.find(params[:assignment][:course_id]).copy_participants(params[:id])
     rescue
       flash[:error] = $!
     end
    end
    @assignment = Assignment.find(params[:id])
    begin 
      oldpath = @assignment.get_path
    rescue
      oldpath = nil
    end
    # The update call below updates only the assignment table. The due dates must be updated separately.
    if @assignment.update_attributes(params[:assignment]) 
      set_limits
      set_weights
      begin
        newpath = @assignment.get_path        
      rescue
        newpath = nil
      end
      if oldpath != nil and newpath != nil
        FileHelper.update_file_location(oldpath,newpath)
      end
      # Iterate over due_dates, from due_date[0] to the maximum due_date
      if params[:due_date]
        for due_date_key in params[:due_date].keys
          due_date_temp = DueDate.find(due_date_key)
          due_date_temp.update_attributes(params[:due_date][due_date_key])
        end
      end
      flash[:notice] = 'Assignment was successfully updated.'
      redirect_to :action => 'show', :id => @assignment                  
    else # Simply refresh the page
      @wiki_types = WikiType.find_all
      render :action => 'edit'
    end    
  end
  
  def show
    @assignment = Assignment.find(params[:id])
  end
  
  def delete
    assignment = Assignment.find(params[:id])
    # If the assignment is already deleted, go back to the list of assignments
    if assignment 
      begin
        assignment.delete_assignment
        AssignmentNode.find_by_node_object_id(params[:id]).destroy
      rescue
        flash[:error] = "The assignment could not be deleted. Cause: "+$!
      end
    end
    
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  def list
    set_up_display_options("ASSIGNMENT")
    @assignments=super(Assignment)
    #    @assignment_pages, @assignments = paginate :assignments, :per_page => 10
  end
  
  def associate_assignment_to_course
    @assignment = Assignment.find(params[:id])
    if session[:user].role_id != Role.find_by_name('Teaching Assistant').id # for other that TA
       @courses = Course.find_all_by_instructor_id(session[:user].id, :order => 'name')
    else
       @courses = TaMapping.get_courses(session[:user].id)
    end   
  end
  
  def remove_assignment_from_course    
    assignment = Assignment.find(params[:id])
    oldpath = assignment.get_path
    assignment.course_id = nil    
    assignment.save
    newpath = assignment.get_path
    FileHelper.update_file_location(oldpath,newpath)
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
end