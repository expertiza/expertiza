class ChangeIsAssignmentConference < ActiveRecord::Migration
  def change
    rename_column :assignments, :is_assignment_conference, :is_conference_assignment
  end
end
