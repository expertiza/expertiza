class DueDate < ActiveRecord::Base
  NO = 1
  LATE = 2
  OK = 3
  
  belongs_to :assignment
  belongs_to :deadline_type
  validate :due_at_is_valid_datetime


  def due_at_is_valid_datetime
    #ignore unnecessary(?) datetime format validation
	#^> They are necessary because null dates yield an invalid comparison when sorting
	
	# puts "Trying to validate this datetime: #{due_at.to_s}..."
    errors.add(:due_at, 'must be a valid datetime') if ((DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError)
  end

  def self.copy(old_assignment_id, new_assignment_id)    
    duedates = find(:all, :conditions => ['assignment_id = ?',old_assignment_id])
    duedates.each{
      |orig_due_date|
      new_due_date = orig_due_date.clone
      new_due_date.assignment_id = new_assignment_id
      new_due_date.save       
    }    
  end
  
  # This was pulled out to its own function because there was an issue with key stringifying with the set_duedate helper
  def self.set_team_formation_deadline(assignment_id, due_at)
    submit_duedate = DueDate.new
	submit_duedate.deadline_type_id = DeadlineType.find_by_name("team_formation").id
	submit_duedate.assignment_id = assignment_id
	submit_duedate.due_at = due_at
	
	# Nothing can be done before teams are formed (set explicitly)
    no_deadline_right = DeadlineRight.find_by_name("No")
	submit_duedate.submission_allowed_id = no_deadline_right.id
	submit_duedate.review_allowed_id = no_deadline_right.id
	submit_duedate.resubmission_allowed_id = no_deadline_right.id
	submit_duedate.rereview_allowed_id = no_deadline_right.id
	submit_duedate.review_of_review_allowed_id = no_deadline_right.id
	submit_duedate.round = 0
	
	submit_duedate.save!
  end
  
  def self.set_duedate (duedate,deadline, assign_id, max_round)
    submit_duedate=DueDate.new(duedate)
    submit_duedate.deadline_type_id = deadline
    submit_duedate.assignment_id = assign_id
    submit_duedate.round = max_round
	
    submit_duedate.save!
  end
  
  def setFlag()
     #puts"~~~~~~~~~enter setFlag"
      self.flag = true
      self.save
     #puts"~~~~~~~~~#{self.flag.to_s}"
    end
end
