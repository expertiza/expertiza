class AddVaryByRoundToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :vary_by_round, :boolean, default: false
  end
end
