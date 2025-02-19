class AddVaryByRoundToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :vary_by_round?, :boolean, default: false
  end
end
