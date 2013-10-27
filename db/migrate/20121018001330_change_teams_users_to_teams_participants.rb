class ChangeTeamsUsersToTeamsParticipants < ActiveRecord::Migration
  def self.up
    begin
      rename_table :teams_participants, :teams_participants
    rescue
    end
  end

  def self.down
  end
end
