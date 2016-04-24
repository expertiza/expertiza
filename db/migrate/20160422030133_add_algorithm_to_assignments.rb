class AddAlgorithmToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :Lauw, :boolean, default: true
  end
end
