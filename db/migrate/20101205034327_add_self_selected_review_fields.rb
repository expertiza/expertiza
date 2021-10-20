class AddSelfSelectedReviewFields < ActiveRecord::Migration
  def self.up
    add_column :assignments, :user_selected_dynamic_reviewer_assignments_enabled, :boolean, :default => 0
    add_column :assignments, :max_dynamic_reviews_per_submission, :integer, :default => 3
  end

  def self.down
    remove_column :assignments, :user_selected_dynamic_reviewer_assignments_enabled
    remove_column :assignments, :max_dynamic_reviews_per_submission
  end
end
