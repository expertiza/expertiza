class CreateParticipantTeamRoles < ActiveRecord::Migration
  def self.up
    create_table :participant_team_roles do |t|
      #t.integer :id
      t.integer :role_assignment_id
      t.integer :participant_id
      t.timestamps
    end
    execute "ALTER TABLE `participant_team_roles`
    ADD CONSTRAINT fk_role_assignment_id
    FOREIGN KEY (role_assignment_id) references teamrole_assignment(id)"
    execute "ALTER TABLE `participant_team_roles`
    ADD CONSTRAINT fk_participant_id
    FOREIGN KEY (participant_id) references participants(id)"
  end

  def self.down
    execute "ALTER TABLE `participant_team_roles`
    DROP FOREIGN KEY fk_role_assignment_id"
    execute "ALTER TABLE `participant_team_roles`
    DROP FOREIGN KEY fk_participant_id"
    drop_table :participant_team_roles
  end
end
