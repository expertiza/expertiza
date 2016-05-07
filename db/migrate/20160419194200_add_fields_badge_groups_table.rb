class AddFieldsBadgeGroupsTable < ActiveRecord::Migration
  def self.up
    add_column :badge_groups, :course_id, :integer
    add_column :badge_groups, :is_course_level_group, :boolean
  end

  def self.down
    remove_column :badge_groups, :course_id, :integer
    remove_column :badge_groups, :is_course_level_group, :boolean
  end
end
