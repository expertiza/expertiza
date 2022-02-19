class AddAlgorithmToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :reputation_algorithm, :string, default: 'Lauw'
  end

  def self.down
    remove_column :assignments, :reputation_algorithm
  end
end
