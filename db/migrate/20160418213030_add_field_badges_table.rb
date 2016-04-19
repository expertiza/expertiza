class AddFieldBadgesTable < ActiveRecord::Migration
  def self.up
    add_column :badges, :credly_badge_id, :integer
  end

  def self.down
    remove_column :assignments, :credly_badge_id, :integer
  end
end
