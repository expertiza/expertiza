class RenameIsDutyBasedAssignmentToDutyBasedAssignment < ActiveRecord::Migration
  def change
    rename_column :assignments, :is_duty_based_assignment, :duty_based_assignment?
  end
end
