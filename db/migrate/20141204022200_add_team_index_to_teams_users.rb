class AddTeamIndexToTeamsUsers < ActiveRecord::Migration
   def change
      add_index :teams_users, :team_id
   end
end
