class SignupSheet < ActiveRecord::Base
  has_many :questions
  has_many :signup_choices
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :waitlist_deadline
  
  def validate
           
    if((start_date != nil) && start_date < Time.now)
      errors.add_to_base("Start Date should be in the future.")
    end
    if((end_date != nil) && end_date < Time.now)
      errors.add_to_base("End Date should be in the future.")
    end
    
    if((waitlist_deadline != nil) && waitlist_deadline < Time.now)
      errors.add_to_base("Waitlist Deadline date should be in the future.")
    end
    
    if((end_date != nil) && (start_date != nil) && (end_date-start_date)<0) 
      errors.add_to_base("End Date should be in the future of Start Date.")
    end
    
     if((waitlist_deadline != nil) && (start_date != nil) && (waitlist_deadline-start_date)<0) 
      errors.add_to_base("Waitlist Deadline date should be in the future of Start Date.")
    end
    
    if((waitlist_deadline != nil) && (end_date != nil) && (waitlist_deadline-end_date)<0) 
      errors.add_to_base("Waitlist Deadline date should be in the future of End Date.")
    end
    
    assignment_due_date = DueDate.find(:all, :conditions=> [" assignment_id= ? and deadline_type_id=?", assignment_id, "2"])
    if(((assignment_due_date[0].due_at-waitlist_deadline)<0) || ((assignment_due_date[0].due_at-start_date)<0) || ((assignment_due_date[0].due_at-end_date)<0)) 
      errors.add_to_base("Signup dates cannot be later than assignmet submission deadline "+assignment_due_date[0].due_at.strftime('%A %B %d %Y, %I:%M%p'))
    end
    
  end  

end
