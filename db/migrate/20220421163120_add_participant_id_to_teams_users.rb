class AddParticipantIdToTeamsUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :teams_users, :participant_id, :integer
  end
end
