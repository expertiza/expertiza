class SubmissionRecord < ActiveRecord::Base
  attr_accessible # TODO: this may break mass assignment upstream. If mass assignment is needed, the fields need to be whiteliste here.
  validates :content, presence: true
  validates :operation, presence: true
  validates :team_id, presence: true
  validates :user, presence: true
  validates :assignment_id, presence: true
end
