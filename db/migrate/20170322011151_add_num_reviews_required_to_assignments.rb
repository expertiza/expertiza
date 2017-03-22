class AddNumReviewsRequiredToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :num_reviews_required, :integer
  end
end
