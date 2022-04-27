class SubmissionRecord < ApplicationRecord
  validates :content, presence: true
  validates :operation, presence: true
  validates :team_id, presence: true
  validates :user, presence: true
  validates :assignment_id, presence: true

  # Copy all submission records for an old assignment to a new assignment
  def self.copy_submission_records_for_assignment(old_assign_id, new_assign_id)
    submission_records_to_copy = SubmissionRecord.where(assignment_id: old_assign_id)
    submission_records_to_copy.each do |original_submission_record|
      new_submission_record = original_submission_record.dup
      new_submission_record.assignment_id = new_assign_id
      new_submission_record.save # should we check if this is successful?
    end
  end
end
