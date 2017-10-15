class AddTeamIndexToTeamsUsers < ActiveRecord::Migration
   def self.up
      #add_index :teams_users, :team_id
   end

   def self.down
   	#remove_index :teams_users, :team_id
   end
end
