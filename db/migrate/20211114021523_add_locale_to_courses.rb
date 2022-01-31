class AddLocaleToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :locale, :integer, default: 1
  end
end
