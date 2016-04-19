class AddFieldBadgeIdBadgeGroupsTable < ActiveRecord::Migration
  def self.up
    add_column :badge_groups, :badge_id, :integer
  end

  def self.down
    remove_column :assignments, :badge_id, :integer
  end

end
