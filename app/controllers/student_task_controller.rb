class StudentTaskController < ApplicationController
  
  def list
    if session[:user].is_new_user
      redirect_to :controller => 'eula', :action => 'display'
    end
    @participants = AssignmentParticipant.find_all_by_user_id(session[:user].id, :order => "parent_id DESC")    
  end
  
  def view
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment    
  end
  
  def others_work
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
    # Finding the current phase that we are in
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment.id])
    @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1, :conditions => ["assignment_id = ?",@assignment.id])
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < next_due_date.due_at
          next_due_date = due_date
        end
      end
    end
    
    @review_phase = next_due_date.deadline_type_id;
    if next_due_date.review_of_review_allowed_id == LATE or next_due_date.review_of_review_allowed_id == OK
      if @review_phase == DeadlineType.find_by_name("metareview").id
        @can_view_metareview = true
      end
    end    
    
    @review_mappings = ReviewMapping.find_all_by_reviewer_id_and_assignment_id(@participant.user_id, @assignment.id)
    @review_of_review_mappings = ReviewOfReviewMapping.find_all_by_reviewer_id(@participant.id)    
  end
  
  def your_work
    
  end
  
  def view_scores
    @participant = AssignmentParticipant.find(params[:id])
    @assignment = @participant.assignment
  end
end
