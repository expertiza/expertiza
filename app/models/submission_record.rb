class SubmissionRecord < ActiveRecord::Base

  # t.datetime "created_at",                  null: false
  # t.datetime "updated_at",                  null: false
  # t.text     "type",          limit: 65535
  # t.string   "content",       limit: 255
  # t.datetime "createdat"
  # t.string   "operation",     limit: 255
  # t.integer  "team_id",       limit: 4
  # t.string   "user",          limit: 255
  # t.integer  "assignment_id", limit: 4

  validates :content, :presence => true
  validates :operation, :presence => true
  validates :team_id, :presence => true
  validates :user, :presence => true
  validates :assignment_id, :presence => true

end
