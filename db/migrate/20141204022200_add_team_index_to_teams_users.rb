class AddTeamIndexToTeamsUsers < ActiveRecord::Migration[4.2]
   def self.up
      #add_index :teams_users, :team_id
   end

  def self.down
    # remove_index :teams_users, :team_id
  end
end
