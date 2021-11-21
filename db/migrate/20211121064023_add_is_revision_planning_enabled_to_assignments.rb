class AddIsRevisionPlanningEnabledToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :is_revision_planning_enabled, :boolean
  end
end
