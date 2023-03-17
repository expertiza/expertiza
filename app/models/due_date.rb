class DueDate < ApplicationRecord
  validate :due_at_is_valid_datetime
  #  has_paper_trail

  def self.default_permission(deadline_type, permission_type)
    DeadlineRight::DEFAULT_PERMISSION[deadline_type][permission_type]
  end

  def self.current_due_date(due_dates)
    # Get the current due date from list of due dates
    due_dates.detect { |due_date| due_date.due_at > Time.now }
  end

  def self.teammate_review_allowed(student)
    # time when teammate review is allowed
    due_date = current_due_date(student.assignment.due_dates)
    student.assignment.find_current_stage == 'Finished' ||
      due_date &&
        (due_date.teammate_review_allowed_id == 3 ||
        due_date.teammate_review_allowed_id == 2) # late(2) or yes(3)
  end

  def due_at_is_valid_datetime
    if due_at.present?
      errors.add(:due_at, 'must be a valid datetime') if (begin
                                                            DateTime.strptime(due_at.to_s, '%Y-%m-%d %H:%M:%S')
                                                          rescue StandardError
                                                            ArgumentError
                                                          end) == ArgumentError
    end
  end

  def self.copy(old_assignment_id, new_assignment_id)
    duedates = where(parent_id: old_assignment_id)
    duedates.each do |orig_due_date|
      new_due_date = orig_due_date.dup
      new_due_date.parent_id = new_assignment_id
      new_due_date.save
    end
  end

  def self.deadline_sort(due_dates)
    due_dates.sort do |m1, m2|
      if m1.due_at && m2.due_at
        m1.due_at <=> m2.due_at
      elsif m1.due_at
        -1
      else
        1
      end
    end
  end

  def self.done_in_assignment_round(assignment_id, response)
    # for author feedback, quiz, teammate review and metareview, Expertiza only support one round, so the round # should be 1
    return 0 if ResponseMap.where(id: response.map_id, type: 'ReviewResponseMap').empty?

    # sorted so that the earliest deadline is at the first
    sorted_deadlines = deadline_sort(DueDate.where(parent_id: assignment_id))
    round = 1
    sorted_deadlines.each do |due_date|
      if response.created_at < due_date.due_at
        break
      elsif due_date.deadline_type_id == 2
        round += 1
      end
    end
    round
  end
end
