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
end
