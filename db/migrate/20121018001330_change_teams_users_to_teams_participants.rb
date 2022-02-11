class ChangeTeamsUsersToTeamsParticipants < ActiveRecord::Migration[4.2][4.2]
  def self.up
    begin
      rename_table :teams_participants, :teams_participants
    rescue
    end
  end

  def self.down
  end
end
