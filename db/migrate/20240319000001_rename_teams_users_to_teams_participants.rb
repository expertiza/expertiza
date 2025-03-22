class RenameTeamsUsersToTeamsParticipants < ActiveRecord::Migration[5.1]
  def up
    # Create the new teams_participants table
    create_table :teams_participants do |t|
      t.integer :team_id, null: false
      t.integer :participant_id, null: false
      t.timestamps
    end

    # Add foreign key constraints
    add_foreign_key :teams_participants, :teams
    add_foreign_key :teams_participants, :participants

    # Add indexes for better performance
    add_index :teams_participants, [:team_id, :participant_id], unique: true
    add_index :teams_participants, :participant_id
    add_index :teams_participants, :team_id
  end

  def down
    drop_table :teams_participants if table_exists?(:teams_participants)
  end
end 