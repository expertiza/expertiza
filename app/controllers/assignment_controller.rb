class AssignmentController < ApplicationController
  
  @no_dl="1" # a value of "no" for whether an action is permitted prior to a deadline
  @late_dl="2" # a value of "late" for whether an action is permitted prior to a deadline (it is permitted, but marked late)
  @ok_dl="3" # a value of "OK" for whether an action is permitted prior to a deadline

  # Deadline types used in the deadline_types DB table
  @Submission_deadline=1;
  @Review_deadline=2;
  @Resubmission_deadline=3;
  @Rereview_deadline=4;
  @Review_of_review_deadline=5;
  
  def new
    @assignment = Assignment.new
    @rubric = Rubric.find_all
  end
  
  def create
    # The Assignment Directory field to be filled in is the path relative to the instructor's home directory (named after his user.name)
    # However, when an administrator creates an assignment, (s)he needs to preface the path with the user.name of the instructor whose assignment it is.
    @assignment = Assignment.new(params[:assignment])
    @assignment.instructor_id = (session[:user]).id
    @duedate=DueDate.new
   

    
    
    if @assignment.save
        submit_duedate=DueDate.new(params[:submit_deadline]);
        submit_duedate.deadline_type_id=@Submission_deadline;
        submit_duedate.assignment_id=@assignment.id;
        submit_duedate.late_policy_id=1;
        submit_duedate.save;
        
        review_duedate=DueDate.new(params[:review_deadline]);
        review_duedate.deadline_type_id=@Review_deadline;
        review_duedate.assignment_id=@assignment.id;
        review_duedate.late_policy_id=1;
        review_duedate.save;
        
        for resubmit_duedate_key in params[:additional_submit_deadline].keys
          resubmit_duedate=DueDate.new(params[:additional_submit_deadline][resubmit_duedate_key]);
          resubmit_duedate.deadline_type_id=@Submission_deadline;
          resubmit_duedate.assignment_id=@assignment.id;
          resubmit_duedate.late_policy_id=1;
          resubmit_duedate.save;
        end
        
        for rereview_duedate_key in params[:additional_review_deadline].keys
          rereview_duedate=DueDate.new(params[:additional_review_deadline][rereview_duedate_key]);
          rereview_duedate.deadline_type_id=@Submission_deadline;
          rereview_duedate.assignment_id=@assignment.id;
          rereview_duedate.late_policy_id=1;
          rereview_duedate.save;
        end
      
        reviewofreview_duedate=DueDate.new(params[:reviewofreview_deadline]);
        reviewofreview_duedate.deadline_type_id=@Review_of_review_deadline;
        reviewofreview_duedate.assignment_id=@assignment.id;
        reviewofreview_duedate.late_policy_id=1;
        reviewofreview_duedate.save;
      
      flash[:notice] = 'Assignment was successfully created.'
      redirect_to :action => 'list'
      
    else
      render :action => 'new'
    end
    
  end
  
  def assign_reviewers
    @assignment = Assignment.find(params[:id])
    @review_strategies = ReviewStrategy.find(:all, :order => 'name')
    @mapping_strategies = MappingStrategy.find(:all, :order => 'name')
  end
  
  def save_reviewer_mappings
    @assignment = Assignment.find(params[:assignment_id])
    if @assignment.update_attributes(params[:assignment])
      ReviewMappings.assign_reviewers(@assignment.id, @assignment.num_reviewers, @assignment.num_review_of_reviewers)
      flash[:notice] = 'Reviewers assigned successfully.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end    
  end
  
  def edit
    @assignment = Assignment.find(params[:id])
  end
  
  def update
    @assignment = Assignment.find(params[:id])
    if @assignment.update_attributes(params[:assignment])
      flash[:notice] = 'Assignment was successfully updated.'
      redirect_to :action => 'show', :id => @assignment
    else
      render :action => 'edit'
    end
  end
  
  def show
    @assignment = Assignment.find(params[:id])
  end
  
  def remove
    
  end
  
  def list
    set_up_display_options("ASSIGNMENT")
    @assignments=super(Assignment)
#    @assignment_pages, @assignments = paginate :assignments, :per_page => 10
  end  
end
