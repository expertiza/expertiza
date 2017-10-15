class DropTableTeamRolesets < ActiveRecord::Migration
  def change
    drop_table :team_rolesets
  end
end
