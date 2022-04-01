class Addiscodingassignmenttoassignments < ActiveRecord::Migration[4.2]
    def self.up
      add_column :assignments, :is_coding_assignment, :boolean
    end

  def self.down
    remove_column :assignments, :is_coding_assignment
  end
end
