class CreateReviewBids < ActiveRecord::Migration
  def change
    create_table :review_bids do |t|
      t.belongs_to :team
      t.belongs_to :participant
      t.integer	   :priority,   :null => false
      t.timestamps null: false
    end
  end
end
