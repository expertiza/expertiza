class AddLeaderboardPrivacyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :leaderboard_privacy, :boolean, :default => false
  end

  def self.down
    remove_column :users, :leaderboard_privacy
  end
end
