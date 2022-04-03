class ChangeTeamIdInBidsTableToUserId < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :bids, :team_id, :user_id
  end

  def self.down
    rename_column :bids, :user_id, :team_id
  end
end
