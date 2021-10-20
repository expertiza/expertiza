class UpdateAssignmentAddRounds < ActiveRecord::Migration
  def self.up
    add_column :assignments, :rounds_of_reviews, :integer, :default => 1
  end

  def self.down
    remove_column :assignments, :rounds_of_reviews
  end
end
