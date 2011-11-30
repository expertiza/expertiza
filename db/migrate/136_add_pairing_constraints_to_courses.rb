class AddPairingConstraintsToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :max_duplicate_pairings, :integer
    add_column :courses, :min_unique_pairings, :integer
  end

  def self.down
    remove_column :courses, :max_duplicate_pairings
    remove_column :courses, :min_unique_pairings
  end
end
