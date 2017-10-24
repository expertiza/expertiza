class DropReviewFiles < ActiveRecord::Migration
  def change
    drop_table :review_files
  end
end
