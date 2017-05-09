class AddNumReviewsToAssignments < ActiveRecord::Migration
  def change
    change_column :assignments, :num_reviews, :integer, :default => 3
  end
end
