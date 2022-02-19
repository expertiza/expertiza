class AddReviewChoosingAlgorthmToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :review_choosing_algorithm, :string, default: 'Simple Choose'
  end

  def self.down
    remove_column :assignments, :review_choosing_algorithm
  end
end
