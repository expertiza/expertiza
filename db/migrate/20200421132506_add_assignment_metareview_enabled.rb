class AddAssignmentMetareviewEnabled < ActiveRecord::Migration
  def change
    add_column :assignments, :metareview_enabled, :boolean, :default => false
  end
end