class AddNodeRgttoNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :lft, :integer
    add_column :nodes, :rgt, :integer
  end
end
