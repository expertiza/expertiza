class AddTeammateReviewAllowedIdToDueDatesTable < ActiveRecord::Migration[4.2]
  def self.up
    add_column :due_dates, :teammate_review_allowed_id, :integer, default: 3
  end

  def self.down
    drop_column :duedates, :teammate_review_allowed_id
  end
end
