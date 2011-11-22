class AddColumnToJoinTeamRequests < ActiveRecord::Migration
  def self.up
    add_column :join_team_requests, :participant_id, :integer
    add_column :join_team_requests, :team_id, :integer
    add_column :join_team_requests, :status, :char
  end

  def self.down
    remove_column :join_team_requests, :status
    remove_column :join_team_requests, :team_id
    remove_column :join_team_requests, :participant_id
  end
end
