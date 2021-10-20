class AddNumReviewsAllowedToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :num_reviews_allowed, :integer, :default => 3
  end
end
