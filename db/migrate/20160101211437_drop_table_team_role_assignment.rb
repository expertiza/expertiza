class DropTableTeamRoleAssignment < ActiveRecord::Migration[4.2]
  def change
    execute 'ALTER TABLE teamrole_assignment DROP FOREIGN KEY fk_teamrole_assignment_team_rolesets;'
    execute 'ALTER TABLE teamrole_assignment DROP FOREIGN KEY fk_teamrole_assignment_assignments;'
    drop_table :teamrole_assignment
  end
end
