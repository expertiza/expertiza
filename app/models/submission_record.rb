class SubmissionRecord < ActiveRecord::Base
  validates :content, presence: true
  validates :operation, presence: true
  validates :team_id, presence: true
  validates :user, presence: true
  validates :assignment_id, presence: true

  def self.file_submissions_present?(assignment_id)
    SubmissionRecord.where(:assignment_id => assignment_id, :operation => "Submit File").present?
  end
end
