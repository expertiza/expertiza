class RenameIsDutyBasedAssignmentToDutyBasedAssignment < ActiveRecord::Migration[4.2]
  def change
    rename_column :assignments, :is_duty_based_assignment, :duty_based_assignment?
  end
end
