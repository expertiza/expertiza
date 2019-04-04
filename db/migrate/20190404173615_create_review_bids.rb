class CreateReviewBids < ActiveRecord::Migration
  def change
    create_table :review_bids do |t|
      t.integer :topic_id
      t.integer :student_id
      t.integer :priority

      t.timestamps null: false
    end
  end
end
