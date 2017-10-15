class ChangeTeamIdInBidsTableToUserId < ActiveRecord::Migration
  def self.up
  	rename_column :bids, :team_id, :user_id
  end

  def self.down
  	rename_column :bids, :user_id, :team_id
  end
end
