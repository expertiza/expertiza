class AddHasBadgeColumnToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :has_badge, :tinyint
  end
end
