# frozen_string_literal: true

# Represents due dates for a specific task or assignment.
class DueDate < ApplicationRecord
  validate :due_at_is_valid_datetime

  # Validates if 'due_at' is a valid datetime, and raises an error if not.
  def due_at_is_valid_datetime
    if due_at.present?
      begin
        DateTime.parse(due_at.to_s)
      rescue StandardError
        errors.add(:due_at, 'must be a valid datetime')
      end
    end
    nil
  end
end
