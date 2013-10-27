class UpdateCourses < ActiveRecord::Migration
  def self.up
    rename_column :courses, :title, :name
    add_column :courses, :created_at, :datetime
    add_column :courses, :updated_at, :datetime
    add_column :courses, :private, :boolean, :default => 0, :null => false
  end

  def self.down
    rename_column :courses, :name, :title
    remove_column :courses, :created_at
    remove_column :courses, :updated_at
    remove_column :courses, :private
  end
end
