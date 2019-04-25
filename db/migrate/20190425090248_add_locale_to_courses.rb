class AddLocaleToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :locale, :string
  end
end
