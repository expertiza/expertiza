class ChangeTeamsUsersToTeamsParticipants < ActiveRecord::Migration
  def self.up
    rename_table :teams_participants, :teams_participants
  rescue StandardError
  end

  def self.down; end
end
