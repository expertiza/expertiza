class AddSimicheckToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :simicheck, :boolean, :default => false
  end
end
