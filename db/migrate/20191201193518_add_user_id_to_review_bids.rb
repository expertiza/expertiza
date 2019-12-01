class AddUserIdToReviewBids < ActiveRecord::Migration
  def change
  	add_column :review_bids, :user_id, :integer
  	add_column :review_bids, :assignment_id, :integer
  	add_foreign_key :review_bids, :users
  	add_foreign_key :review_bids, :assignments
  end
end
