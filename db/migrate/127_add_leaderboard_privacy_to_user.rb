<<<<<<< HEAD
class AddLeaderboardPrivacyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :leaderboard_privacy, :boolean, :default => false
  end

  def self.down
    remove_column :users, :leaderboard_privacy
  end
end
=======
class AddLeaderboardPrivacyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :leaderboard_privacy, :boolean, :default => false
  end

  def self.down
    remove_column :users, :leaderboard_privacy
  end
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
