class DueDate < ActiveRecord::Base
  NO = 1
  LATE = 2
  OK = 3

  belongs_to :assignment
  belongs_to :deadline_type
  validate :due_at_is_valid_datetime


  def due_at_is_valid_datetime
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

  def self.set_duedate (duedate,deadline, assign_id, max_round)
    submit_duedate=DueDate.new(duedate);
    submit_duedate.deadline_type_id = deadline;
    submit_duedate.assignment_id = assign_id
    submit_duedate.round = max_round;
    submit_duedate.save;
  end

  def setFlag()
     #puts"~~~~~~~~~enter setFlag"
      self.flag = true
      self.save
     #puts"~~~~~~~~~#{self.flag.to_s}"
  end

   def get_current_due_date()
    #puts "~~~~~~~~~~Enter get_current_due_date()\n"
    due_date = Assignment.find_current_stage()
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return due_date
    end

  end

  def get_next_due_date()
    #puts "~~~~~~~~~~Enter get_next_due_date()\n"
    due_date = Assignment.find_next_stage()

    if due_date == nil or due_date == COMPLETE
      return nil
    else
      return due_date
    end

  end


end
