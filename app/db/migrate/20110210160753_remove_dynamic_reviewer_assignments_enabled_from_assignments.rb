class RemoveDynamicReviewerAssignmentsEnabledFromAssignments < ActiveRecord::Migration
  def self.up
    remove_column :assignments, :dynamic_reviewer_assignments_enabled
  end

  def self.down
    add_column :assignments, :dynamic_reviewer_assignments_enabled, :boolean, :default => 0
  end
end
