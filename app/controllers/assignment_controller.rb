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
    new_assign.instructor_id = session[:user].id
    new_assign.name = 'Copy of '+new_assign.name 
   
    if new_assign.save    
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
  end
  
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
    @assignment.instructor_id = (session[:user]).id
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
    @wiki_types = WikiType.find_all
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
    # The update call below updates only the assignment table. The due dates must be updated separately.
    if @assignment.update_attributes(params[:assignment])
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
    
  def ror_for_instructors
    @reviewer_id = session[:user].id
    @assignment_id = params[:id]
    @reviews = Array.new
    review_mappings = ReviewMapping.find(:all,:conditions => ["assignment_id = ?", params[:id]])
    for review_mapping in review_mappings
      if Review.find_by_review_mapping_id(review_mapping.id)
        @reviews << Review.find_by_review_mapping_id(review_mapping.id)
      end
    end    
  end
  
  def assign
    @assignment = Assignment.find(params[:id])
    @courses = Course.find_all_by_instructor_id(session[:user].id, :order => 'name')
  end
  
  def remove
    assignment = Assignment.find(params[:id])
    assignment.course_id = nil    
    assignment.save
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
end