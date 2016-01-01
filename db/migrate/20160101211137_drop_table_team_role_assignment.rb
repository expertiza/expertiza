class DropTableTeamRoleAssignment < ActiveRecord::Migration
  def change
    drop_table :teamrole_assignment
  end
end
