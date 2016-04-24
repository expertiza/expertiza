class AddColumnBadgesAwardedBadgeGroups < ActiveRecord::Migration
  def self.up
    add_column :badge_groups, :badges_awarded, :boolean, default: false
  end

  def self.down
    remove_column :badge_groups, :badges_awarded, :boolean
  end
end
