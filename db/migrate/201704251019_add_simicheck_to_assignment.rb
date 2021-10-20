class AddSimicheckToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :simicheck, :integer, :default => -1
  end
end