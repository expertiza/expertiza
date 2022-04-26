class AddParticipantIdToTeamsUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :teams_users, :participant, type: :integer, foreign_key: true
  end
end
