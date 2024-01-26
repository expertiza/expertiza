class AddLeaderboardPrivacyToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :leaderboard_privacy, :boolean, default: false
  end

  def self.down
    remove_column :users, :leaderboard_privacy
  end
end
