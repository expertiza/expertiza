class DueDate < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :deadline_type
  validate :due_at_is_valid_datetime
  #  has_paper_trail

  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end

  def type
    self.deadline_type.name
  end

  def set_flag
    self.flag = true
    self.save
  end

  def due_at_is_valid_datetime
    unless due_at.blank?
      errors.add(:due_at, 'must be a valid datetime') if (DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S') rescue ArgumentError) == ArgumentError
    end
  end

  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(['assignment_id = ?', old_assignment_id])
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.assignment_id = new_assignment_id
      new_due_date.save
    end
  end

  def self.set_duedate(duedate, deadline, assign_id, max_round)
    submit_duedate = DueDate.new(duedate)
    submit_duedate.deadline_type_id = deadline
    submit_duedate.assignment_id = assign_id
    submit_duedate.round = max_round
    submit_duedate.save
  end

  def self.deadline_sort(due_dates)
    due_dates.sort {|m1, m2| (m1.due_at and m2.due_at) ? m1.due_at <=> m2.due_at : (m1.due_at ? -1 : 1) }
  end

  def self.done_in_assignment_round(assignment_id, response)
    # for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    return 0 if ResponseMap.find(response.map_id).type != "ReviewResponseMap"
    due_dates = DueDate.where(["assignment_id = ?", assignment_id])
    sorted_deadlines = []
    # sorted so that the earliest deadline is at the first
    sorted_deadlines = deadline_sort(due_dates)
    due_dates.reject {|due_date| due_date.type != 1 && due_date.type != 2 }
    round = 1
    for due_date in sorted_deadlines
      break if response.created_at < due_date.due_at
      round += 1 if due_date.type == 2
    end
    round
  end
end
