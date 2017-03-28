class AddNumReviewsRequiredToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :num_reviews_required, :integer, :default => 0
  end
end
