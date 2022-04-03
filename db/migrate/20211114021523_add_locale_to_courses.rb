class AddLocaleToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :locale, :integer, default: 1
  end
end
