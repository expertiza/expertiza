class AddShowTeammateReviewsToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :show_teammate_reviews, :boolean
  end
end
