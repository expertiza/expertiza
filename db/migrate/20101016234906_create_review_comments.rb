class CreateReviewComments < ActiveRecord::Migration
  def self.up
    create_table :review_comments do |t|
      t.text :comment
      t.text :severity
      t.integer :line_number
      t.integer :review_file_id
      t.integer :reviewer_id
      t.timestamps
    end
  end

  def self.down
    drop_table :review_comments
  end
end
