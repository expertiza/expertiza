# frozen_string_literal: true

# The `review_choosing_algorithm` column is intended to store the algorithm used for selecting
# reviews within an assignment. This could be used to implement various strategies such as
# "Simple Choose", "Bidding", "Random", etc., allowing for flexibility in how reviews are assigned.
class AddReviewChoosingAlgorithmToAssignments < ActiveRecord::Migration[5.1]
  def self.up
    add_column :assignments, :review_choosing_algorithm, :string, default: 'Simple Choose'
  end

  def self.down
    remove_column :assignments, :review_choosing_algorithm
  end
end
