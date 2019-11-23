class CreateReviewBids < ActiveRecord::Migration
  def change
    create_table :review_bids do |t|
      t.integer :priority 
      t.integer :sign_up_topic_id
      t.integer :participant_id
      t.timestamps 
    end
    add_foreign_key  :review_bids, :sign_up_topics
    add_foreign_key  :review_bids, :participants
  end
end
