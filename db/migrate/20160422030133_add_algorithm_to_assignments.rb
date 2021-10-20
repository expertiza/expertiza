class AddAlgorithmToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :reputation_algorithm, :string, default: 'Lauw'
  end

  def self.down
  	remove_column :assignments, :reputation_algorithm
  end
end
