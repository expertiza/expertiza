class SubmissionRecord < ActiveRecord::Base
  validates :content, presence: true
  validates :operation, presence: true
  validates :team_id, presence: true
  validates :user, presence: true
  validates :assignment_id, presence: true


  def self.copy_calibrated_submissions(old_assign, new_assign_id)
    @prev_submission_records = SubmissionRecord.where(assignment_id: old_assign.id)
    @prev_submission_records.each do |prev_submission_record|
      @new_submission_record = SubmissionRecord.new
      @new_submission_record.type = prev_submission_record.type
      @new_submission_record.content = prev_submission_record.content
      @new_submission_record.operation = prev_submission_record.operation
      @new_submission_record.team_id = prev_submission_record.team_id
      @new_submission_record.user = prev_submission_record.user
      @new_submission_record.assignment_id = new_assign_id
      @new_submission_record.save
    end
  end

end
