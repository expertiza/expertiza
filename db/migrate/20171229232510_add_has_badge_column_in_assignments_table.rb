class AddHasBadgeColumnInAssignmentsTable < ActiveRecord::Migration
  def change
    add_column :assignments, :has_badge, :boolean
  end
end
