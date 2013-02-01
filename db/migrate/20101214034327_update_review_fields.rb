class UpdateReviewFields < ActiveRecord::Migration
  def self.up
    add_column :assignments, :review_assignment_strategy, :string
    add_column :assignments, :max_reviews_per_submission, :integer
    remove_column :assignments, :dynamic_reviewer_response_time_limit_hours
    remove_column :response_maps, :potential_response_deadline
    remove_column :assignments, :user_selected_dynamic_reviewer_assignments_enabled
    remove_column :assignments, :max_dynamic_reviews_per_submission
  end

  def self.down
    remove_column :assignments, :review_assignment_strategy
    remove_column :assignments, :max_reviews_per_submission
    add_column :response_maps, :potential_response_deadline, :datetime, :null => true
    add_column :assignments, :dynamic_reviewer_assignments_enabled, :boolean, :default => 0
    add_column :assignments, :dynamic_reviewer_response_time_limit_hours, :integer    
    add_column :assignments, :user_selected_dynamic_reviewer_assignments_enabled, :boolean, :default => 0
    add_column :assignments, :max_dynamic_reviews_per_submission, :integer, :default => 3
  end
end
