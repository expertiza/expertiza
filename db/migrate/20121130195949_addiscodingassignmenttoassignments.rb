class Addiscodingassignmenttoassignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :is_coding_assignment, :integer
  end

  def self.down
    remove :assignments, :is_coding_assignment
  end
end
