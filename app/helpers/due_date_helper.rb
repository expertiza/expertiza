module DueDatesHelper
  def current_due_date(due_dates)
    due_dates.each do |due_date|
      if due_date.due_at > Time.now
        current_due_date = due_date
        return current_due_date
      end
    end
    # in case current due date not found
    nil
  end

  def self.teammate_review_allowed(student)
    # time when teammate review is allowed
    due_date = current_due_date(student.assignment.due_dates)
    student.assignment.find_current_stage == 'Finished' ||
      due_date &&
        (due_date.teammate_review_allowed_id == 3 ||
        due_date.teammate_review_allowed_id == 2) # late(2) or yes(3)
  end
end
