module AssignmentsHelper
  require 'date'
  COMPLETE = "Finished"
  WAITLIST = "Waitlist open"
  
  def self.find_current_stage(signup_id)
    due_dates = SignupSheet.find(:all, 
                 :conditions => ["id = ?", signup_id])
                 
    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].end_date
        return COMPLETE
      elsif Time.now > due_dates[0].end_date && Time.now < due_dates[0].waitlist_deadline
        return WAITLIST
      else
        return due_dates[0].end_date
      end
    end
  end
  
  def self.get_stage_deadline(assignment_id)
    due_date = find_current_stage(assignment_id)
    if due_date != nil and due_date != COMPLETE
      return due_date.strftime('%A %B %d %Y, %I:%M%p')
    else
      return due_date
    end
  end
end
