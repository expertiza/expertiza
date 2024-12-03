class RenameTeamsUsersToTeamsParticipants < ActiveRecord::Migration[5.1]
  def change
    # Rename the table
    rename_table :teams_users, :teams_participants

    # Remove the existing foreign key
    remove_foreign_key :teams_participants, :participants

    # Add the foreign key back with the proper name
    add_foreign_key :teams_participants, :participants, column: :participant_id, name: 'fk_teams_participants'
  end
end
