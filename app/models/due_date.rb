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
  
end
