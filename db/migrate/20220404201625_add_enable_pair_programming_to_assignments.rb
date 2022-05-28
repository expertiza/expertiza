class AddEnablePairProgrammingToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :enable_pair_programming, :boolean
  end
end
