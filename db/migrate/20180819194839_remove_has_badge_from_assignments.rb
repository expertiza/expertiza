class RemoveHasBadgeFromAssignments < ActiveRecord::Migration
  def change
    remove_column :assignments, :has_badge, :tinyint
  end
end
