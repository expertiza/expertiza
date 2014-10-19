class CreateTeamRolesetsMaps < ActiveRecord::Migration
  def self.up
    create_table :team_rolesets_maps   do |t|
      #t.integer :id
      t.integer :team_rolesets_id
      t.integer :team_role_id
      t.timestamps
    end
    execute "ALTER TABLE `team_rolesets_maps`
    ADD CONSTRAINT fk_team_rolesets_id
    FOREIGN KEY (team_rolesets_id) references team_rolesets(id)"
    execute "ALTER TABLE `team_rolesets_maps`
    ADD CONSTRAINT fk_team_role_id
    FOREIGN KEY (team_role_id) references team_roles(id)"
  end

  def self.down
    execute "ALTER TABLE `team_rolesets_maps`
    DROP FOREIGN KEY fk_team_rolesets_id"
    execute "ALTER TABLE `team_rolesets_maps`
    DROP FOREIGN KEY fk_team_role_id"
    drop_table :team_rolesets_maps
  end
end
