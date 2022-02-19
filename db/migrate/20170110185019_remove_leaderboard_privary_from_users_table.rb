class RemoveLeaderboardPrivaryFromUsersTable < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :users, :leaderboard_privacy
  end

  def self.down
    add_column :users, :leaderboard_privacy, :boolean, default: false
  end
end
