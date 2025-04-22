# db/migrate/20240319000001_rename_teams_users_to_teams_participants.rb
class RenameTeamsUsersToTeamsParticipants < ActiveRecord::Migration[5.1]
  def up
    if table_exists?(:teams_users)
      rename_table :teams_users, :teams_participants
    end
  end

  def down
    if table_exists?(:teams_participants)
      rename_table :teams_participants, :teams_users
    end
  end
end
  