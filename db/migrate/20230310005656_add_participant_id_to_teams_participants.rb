class AddParticipantIdToTeamsParticipants < ActiveRecord::Migration[5.1]
  def change
    add_column :teams_participants, :participant_id, :integer, limit: 4, index: true
    add_foreign_key :teams_participants, :participants
  end
end