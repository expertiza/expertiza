class DropTableTeamRolesets < ActiveRecord::Migration[4.2]
  def change
    drop_table :team_rolesets
  end
end
