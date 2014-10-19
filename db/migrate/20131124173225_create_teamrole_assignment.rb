class CreateTeamroleAssignment < ActiveRecord::Migration
  def self.up
    create_table "teamrole_assignment", :force => true do |t|
      #t.integer "id"
      t.integer "team_roleset_id"
      t.integer "assignment_id"
    end
    execute "ALTER TABLE `teamrole_assignment`
             ADD CONSTRAINT `fk_teamrole_assignment_team_rolesets`
             FOREIGN KEY (team_roleset_id) references team_rolesets(id)"
    execute "ALTER TABLE `teamrole_assignment`
             ADD CONSTRAINT `fk_teamrole_assignment_assignments`
             FOREIGN KEY (assignment_id) references assignments(id)"

  end

  def self.down
    execute "ALTER TABLE `teamrole_assignment`
             DROP FOREIGN KEY `fk_teamrole_assignment_team_rolesets`"
    execute "ALTER TABLE `teamrole_assignment`
             DROP FOREIGN KEY `fk_teamrole_assignment_assignments`"
    drop_table :teamrole_assignment
  end
end
