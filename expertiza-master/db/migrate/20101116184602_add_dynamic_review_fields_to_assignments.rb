class AddDynamicReviewFieldsToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :dynamic_reviewer_assignments_enabled, :boolean, :default => 0
    add_column :assignments, :dynamic_reviewer_response_time_limit_hours, :integer
  end

  def self.down
    remove_column :assignments, :potential_response_deadline
    remove_column :assignments, :dynamic_reviewer_response_time_limit_hours
  end
end
