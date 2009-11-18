class DueDate < ActiveRecord::Base
  belongs_to :submission_allowed,       :class_name => "DeadlineRight", :foreign_key => "submission_allowed_id"
  belongs_to :resubmission_allowed,     :class_name => "DeadlineRight", :foreign_key => "resubmission_allowed_id"
  belongs_to :review_allowed,           :class_name => "DeadlineRight", :foreign_key => "review_allowed_id"
  belongs_to :rereview_allowed,         :class_name => "DeadlineRight", :foreign_key => "rereview_allowed_id"
  belongs_to :review_of_review_allowed, :class_name => "DeadlineRight", :foreign_key => "review_of_review_allowed_id"

  
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
