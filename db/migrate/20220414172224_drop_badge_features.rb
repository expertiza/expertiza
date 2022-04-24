class DropBadgeFeatures < ActiveRecord::Migration[5.1]
  def change
    remove_column :assignments, :has_badge if Assignment.column_names.include? :has_badge
    drop_table :assignment_badges if ActiveRecord::Base.connection.table_exists? 'assignment_badges'
  end
end
