class AddIsAssignmentConferenceToAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :is_assignment_conference, :boolean, default: false
  end
end
