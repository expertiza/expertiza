class DropReviewComments < ActiveRecord::Migration[4.2]
  def change
    drop_table :review_comments
  end
end
