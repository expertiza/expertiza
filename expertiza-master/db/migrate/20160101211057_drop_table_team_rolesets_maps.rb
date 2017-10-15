class DropTableTeamRolesetsMaps < ActiveRecord::Migration
  def change
    drop_table :team_rolesets_maps
  end
end
