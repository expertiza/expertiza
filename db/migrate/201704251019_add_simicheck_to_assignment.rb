class AddSimicheckToAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :simicheck, :integer, default: -1
  end
end
