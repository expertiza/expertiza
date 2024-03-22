class RenameTeamsUsersToTeamsParticipants < ActiveRecord::Migration[5.1]
  def change
    # Check if the 'teams_users' table exists and 'teams_participants' does not exist
    if table_exists?(:teams_users) && !table_exists?(:teams_participants)
      rename_table :teams_users, :teams_participants
    elsif table_exists?(:teams_participants)
      puts "'teams_participants' table already exists. Migration skipped."
    else
      puts "'teams_users' table does not exist. Migration skipped."
    end
  end

  def down
    # Check if the 'teams_participants' table exists and 'teams_users' does not exist
    if table_exists?(:teams_participants) && !table_exists?(:teams_users)
      rename_table :teams_participants, :teams_users
    elsif table_exists?(:teams_users)
      puts "'teams_users' table already exists. Reverse migration skipped."
    else
      puts "'teams_participants' table does not exist. Reverse migration skipped."
    end
  end
end
