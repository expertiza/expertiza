class AddDetailsToDueDates < ActiveRecord::Migration
  def self.up
    add_column :due_dates, :teammate_review_allowed_id, :integer
    add_column :due_dates, :survey_response_allowed_id, :integer
    add_column :due_dates, :signup_allowed_id, :integer
    add_column :due_dates, :drop_allowed_id, :integer
    add_column :due_dates, :author_feedback_allowed_id, :integer
  end

  def self.down
    remove_column :due_dates, :author_feedback_allowed_id
    remove_column :due_dates, :drop_allowed_id
    remove_column :due_dates, :signup_allowed_id
    remove_column :due_dates, :survey_response_allowed_id
    remove_column :due_dates, :teammate_review_allowed_id
  end
end
