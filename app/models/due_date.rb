class DueDate < ApplicationRecord
  validate :due_at_is_valid_datetime
  # has_paper_trail

  # Validates if 'due_at' is a valid datetime, and raises an error if not.
  def due_at_is_valid_datetime
    if due_at.present?
      begin
        DateTime.parse(due_at.to_s)
      rescue ArgumentError, StandardError
        errors.add(:due_at, 'must be a valid datetime')
      end
    end
	nil
  end

end
