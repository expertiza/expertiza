class AddNumReviewsRequiredToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :num_reviews_required, :integer, default: 3
  end
end
