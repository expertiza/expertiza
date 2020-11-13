class AddIsConferenceToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :is_assignment_conference, :boolean, :default => false
  end
end
