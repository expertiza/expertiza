class DueDate < ActiveRecord::Base
  
  def self.copy(old_assignment_id, new_assignment_id)    
    duedates = find(:all, :conditions => ['assignment_id = ?',old_assignment_id])
    duedates.each{
      |orig_due_date|
      new_due_date = orig_due_date.clone
      new_due_date.assignment_id = new_assignment_id
      new_due_date.save       
    }    
  end
  
  def self.set_duedate (duedate,deadline, assign_id, max_round)
    submit_duedate=DueDate.new(duedate);
    submit_duedate.deadline_type_id = deadline;
    submit_duedate.assignment_id = assign_id
    submit_duedate.round = max_round; 
    submit_duedate.save;
  end
end
