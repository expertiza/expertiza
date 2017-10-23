class GitDatum < ActiveRecord::Base
  belongs_to :SubmissionRecord
  validate :pull_request, presence :true
  validate :submission_record_id
  validate :author, presence :true
  validate :commits, presence :true
  validate :files, presence :true
  validate :additions, presence :true
  validate :deletions, presence :true
  validate :date, presence :true

end
