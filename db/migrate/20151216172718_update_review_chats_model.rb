class UpdateReviewChatsModel < ActiveRecord::Migration
  def change
  	remove_column("review_chats","assignment_id")
	remove_column("review_chats","team_id")
	remove_column("review_chats","reviewer_id")
	add_column("review_chats","map_id", :integer)   
  end
end
