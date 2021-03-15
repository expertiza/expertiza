class UpdateReviewTimeSchema < ActiveRecord::Migration
  def change
    add_column :submission_viewing_events, :total_time, :integer, :default => 0, column_options: { null: false }
  end
end
