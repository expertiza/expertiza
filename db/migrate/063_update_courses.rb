class UpdateCourses < ActiveRecord::Migration
  def self.up
    rename_column :courses, :title, :name
    add_column :courses, :created_at, :datetime
  end

  def self.down
    rename_column :courses, :name, :title
    remove_column :courses, :created_at
  end
end
