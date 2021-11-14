class AddLocaleToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :locale, :integer, default: 0
  end
end
