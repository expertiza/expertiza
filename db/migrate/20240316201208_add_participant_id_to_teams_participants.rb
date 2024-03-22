class AddParticipantIdToTeamsParticipants < ActiveRecord::Migration[5.1]
    def change
      add_column :teams_participants, :participant_id, :integer
      add_foreign_key :teams_participants, :participants, column: :participant_id
    end
  end