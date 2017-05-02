class SubmissionRecord < ActiveRecord::Base
  validates :content, :presence => true
  validates :operation, :presence => true
  validates :team_id, :presence => true
  validates :user, :presence => true
  validates :assignment_id, :presence => true
  has_many :github_contributors, :dependent => :delete_all
end
