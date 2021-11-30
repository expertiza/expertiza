class UpdateVaryByRoundToAssignments < ActiveRecord::Migration
  def change
    change_column :assignments, :vary_by_round, :boolean, :default => true
  end
end
