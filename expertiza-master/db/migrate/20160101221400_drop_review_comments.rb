class DropReviewComments < ActiveRecord::Migration
  def change
    drop_table :review_comments
  end
end
