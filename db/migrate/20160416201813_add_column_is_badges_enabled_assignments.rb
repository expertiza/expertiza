class AddColumnIsBadgesEnabledAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :is_badges_enabled, :boolean
  end

  def self.down
    remove_column :assignments, :is_badges_enabled, :boolean
  end
end
