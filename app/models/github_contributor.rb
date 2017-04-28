class GithubContributor < ActiveRecord::Base
  validates :user_name, :presence => true
  validates :github_id, :presence => true
  validates :total_commits, :presence => true
  validates :files_changed, :presence => true
  validates :lines_changed, :presence => true
  validates :lines_added, :presence => true
  validates :lines_removed, :presence => true
  validates :lines_persisted, :presence => true
  validates :lines_persisted, :presence => true
  validates :submission_records_id, :presence => true
end