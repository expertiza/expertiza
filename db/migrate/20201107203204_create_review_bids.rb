class CreateReviewBids < ActiveRecord::Migration[4.2]
  def change
    create_table :review_bids do |t|
      t.integer  'priority',       limit: 4
      t.integer  'signuptopic_id', limit: 4
      t.integer  'participant_id', limit: 4
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.integer  'user_id',        limit: 4
      t.integer  'assignment_id',  limit: 4
      t.timestamps null: false
    end

    add_index 'review_bids', ['assignment_id'], name: 'fk_rails_549e23ae08', using: :btree
    add_index 'review_bids', ['participant_id'], name: 'fk_rails_ab93feeb35', using: :btree
    add_index 'review_bids', ['signuptopic_id'], name: 'fk_rails_e88fa4058f', using: :btree
    add_index 'review_bids', ['user_id'], name: 'fk_rails_6041e1cdb9', using: :btree

    add_foreign_key 'review_bids', 'assignments'
    add_foreign_key 'review_bids', 'participants'
    add_foreign_key 'review_bids', 'sign_up_topics', column: 'signuptopic_id'
    add_foreign_key 'review_bids', 'users'
  end
end
