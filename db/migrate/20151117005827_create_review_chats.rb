class CreateReviewChats < ActiveRecord::Migration
  def change
    create_table :review_chats do |t|
      t.integer :assignment_id
      t.integer :reviewer_id
      t.integer :team_id
      t.string :type_flag
      t.string :content

      t.timestamps null: false
    end
  end
end
