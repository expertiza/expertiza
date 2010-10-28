class CreateReviewFiles < ActiveRecord::Migration
  def self.up
    create_table :review_files do |t|
      t.string :file_path
      t.string :file_name
      t.boolean :accepted
      t.text :file_comment
      t.integer :code_review_id
      t.datetime :upload_time
      t.timestamps
    end
  end

  def self.down
    drop_table :review_files
  end
end
