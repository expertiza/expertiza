class RenameSignedUpUsersToSignedUpTeams < ActiveRecord::Migration
  def self.up
  	rename_table :signed_up_users, :signed_up_teams
  end

  def self.down
  	rename_table :signed_up_teams, :signed_up_users
  end
end
