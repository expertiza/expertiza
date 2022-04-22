class SubmissionRecord < ApplicationRecord
  validates :content, presence: true
  validates :operation, presence: true
  validates :team_id, presence: true
  validates :user, presence: true
  validates :assignment_id, presence: true

  def self.copy_assignment_submissions(old_assign, new_assign_id)
    @prev_submission_record = SubmissionRecord.where(assignment_id: old_assign.id)
    @prev_submission_record.each do |catt|
      @new_submission_record = SubmissionRecord.new
      @new_submission_record.type = catt.type
      @new_submission_record.content = catt.content
      @new_submission_record.operation = catt.operation
      @new_submission_record.team_id = catt.team_id
      @new_submission_record.user = catt.user
      @new_submission_record.assignment_id = new_assign_id
      @new_submission_record.save
    end
  end
end
