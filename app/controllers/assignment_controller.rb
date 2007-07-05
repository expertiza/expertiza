class AssignmentController < ApplicationController
  
  before_filter :authorize

  @no_dl="1" # a value of "no" for whether an action is permitted prior to a deadline
  @late_dl="2" # a value of "late" for whether an action is permitted prior to a deadline (it is permitted, but marked late)
  @ok_dl="3" # a value of "OK" for whether an action is permitted prior to a deadline
  def new
    @assignment = Assignment.new
    @rubric = Rubric.find_all
    @wiki_types = WikiType.find_all
  end
  
  def create
    # The Assignment Directory field to be filled in is the path relative to the instructor's home directory (named after his user.name)
    # However, when an administrator creates an assignment, (s)he needs to preface the path with the user.name of the instructor whose assignment it is.
    @assignment = Assignment.new(params[:assignment])
    @assignment.instructor_id = (session[:user]).id
    @assignment.submitter_count = 0
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
      submit_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
      submit_duedate.save;
      
      review_duedate=DueDate.new(params[:review_deadline]);
      review_duedate.deadline_type_id=@Review_deadline;
      review_duedate.assignment_id=@assignment.id;
      review_duedate.late_policy_id=1;
      review_duedate.save;
      
      if params[:assignment_helper][:no_of_reviews].to_i >= 2
        for resubmit_duedate_key in params[:additional_submit_deadline].keys
          resubmit_duedate=DueDate.new(params[:additional_submit_deadline][resubmit_duedate_key]);
          resubmit_duedate.deadline_type_id=@Resubmission_deadline;
          resubmit_duedate.assignment_id=@assignment.id;
          resubmit_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
          resubmit_duedate.save;
        end
        
        for rereview_duedate_key in params[:additional_review_deadline].keys
          rereview_duedate=DueDate.new(params[:additional_review_deadline][rereview_duedate_key]);
          rereview_duedate.deadline_type_id=@Rereview_deadline;
          rereview_duedate.assignment_id=@assignment.id;
          rereview_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
          rereview_duedate.save;
        end
      end      
      reviewofreview_duedate=DueDate.new(params[:reviewofreview_deadline]);
      reviewofreview_duedate.deadline_type_id=@Review_of_review_deadline;
      reviewofreview_duedate.assignment_id=@assignment.id;
      reviewofreview_duedate.late_policy_id=params[:for_due_date][:late_policy_id];
      reviewofreview_duedate.save;
      
      flash[:notice] = 'Assignment was successfully created.'
      redirect_to :action => 'list'
      
    else
      @wiki_types = WikiType.find_all
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
      @wiki_types = WikiType.find_all
      render :action => 'edit'
    end    
  end
  
  def edit
    @assignment = Assignment.find(params[:id])
    @wiki_types = WikiType.find_all
  end
  
  def update
    @assignment = Assignment.find(params[:id])
    if @assignment.update_attributes(params[:assignment])
      
      for due_date_key in params[:due_date].keys
        due_date_temp = DueDate.find(due_date_key)
        due_date_temp.update_attributes(params[:due_date][due_date_key])
      end
      flash[:notice] = 'Assignment was successfully updated.'
      redirect_to :action => 'show', :id => @assignment
    else
      @wiki_types = WikiType.find_all
      render :action => 'edit'
    end
  end
  
  def show
    @assignment = Assignment.find(params[:id])
  end
  
  def delete
    @assignment = get(Assignment, params[:id])
    if @assignment == nil
      redirect_to :action => 'list' 
    else 
      if @assignment.due_dates_exist? == false or params['delete'] or @assignment.review_feedback_exist? == false or @assignment.participants_exist? == false
        @assignment.delete_due_dates
        @assignment.delete_review_feedbacks
        @assignment.delete_participants
        @assignment.destroy
        redirect_to :action => 'list'
      end
    end
  end

  
  def list
    set_up_display_options("ASSIGNMENT")
    @assignments=super(Assignment)
    #    @assignment_pages, @assignments = paginate :assignments, :per_page => 10
  end
  
end
