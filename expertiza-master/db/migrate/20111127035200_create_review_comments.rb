class CreateReviewComments < ActiveRecord::Migration
  def self.up
    create_table :review_comments do |t|
      t.integer :review_file_id
      t.text :comment_content
      t.integer :reviewer_participant_id
      t.integer :file_offset

      t.timestamps
    end
  end

  def self.down
    drop_table :review_comments
  end
end
