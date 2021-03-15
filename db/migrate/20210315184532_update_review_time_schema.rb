class UpdtaeReviewTimeSchema < ActiveRecord::Migration
  def change
    add_column :submission_viewing_events, :total_time, :integer
  end
end
