class DropTableTeamRoles < ActiveRecord::Migration
  def change
    drop_table :team_roles
  end
end
