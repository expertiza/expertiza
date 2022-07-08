class AddEnablePairProgrammingToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :pair_programming_enabled?, :boolean, default: false
  end
end
