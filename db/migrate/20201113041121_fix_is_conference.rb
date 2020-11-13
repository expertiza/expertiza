class FixIsConference < ActiveRecord::Migration
  def change
    rename_column :assignments, :is_assignment_conference, :is_assignment_conference

  end
end
