class AddParticipantIdToTeamsParticipants < ActiveRecord::Migration[5.1]
  def change
    unless column_exists?(:teams_participants, :participant_id)
      add_column :teams_participants, :participant_id, :integer
    end
  end
end