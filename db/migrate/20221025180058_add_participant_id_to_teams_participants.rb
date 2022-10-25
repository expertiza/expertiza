class AddParticipantIdToTeamsParticipants < ActiveRecord::Migration[5.1]
  def change
    add_column :teams_participants, :participant_id, :integer
    add_reference :teams_participants, :participants, index: true, foreign_key: true
  end
end
