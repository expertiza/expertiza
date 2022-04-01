class DropReviewFiles < ActiveRecord::Migration[4.2]
  def change
    drop_table :review_files
  end
end
