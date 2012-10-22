class ReportsController < ApplicationController
  def view
    @assignment_id=14;
    
    @due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",@assignment_id])
    @late_policy = Assignment.find(@assignment_id).late_policy
    # Find the next due date (after the current date/time), and then find the type of deadline it is.
    @very_last_due_date = DueDate.find(:all,:order => "due_at DESC", :limit =>1)
    @next_due_date = @very_last_due_date[0]
    for due_date in @due_dates
      if due_date.due_at > Time.now
        if due_date.due_at < @next_due_date.due_at
          @next_due_date = due_date
        end
      end
    end
    
    
    @review_phase = @next_due_date.deadline_type_id;
    
    
    
  end
end
