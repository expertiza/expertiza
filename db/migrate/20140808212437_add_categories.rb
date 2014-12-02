class AddCategories < ActiveRecord::Migration
  def change
     add_column :nodes, :name, :string
     add_column :nodes, :lft, :integer
     add_column :nodes, :rgt, :integer
     add_column :nodes, :depth, :integer
  end
end
