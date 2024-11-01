class DropTableTeamRolesetsMaps < ActiveRecord::Migration[4.2]
  def change
    drop_table :team_rolesets_maps
  end
end
