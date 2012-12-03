class CreateAssignmentReviewWeights < ActiveRecord::Migration
  def self.up
    create_table :assignment_review_weights do |t|
      t.integer :assignment_id
      t.float :review_weight
      t.float :metareview_weight
      t.integer :review_points
      t.integer :metareview_points

      t.timestamps
    end
  end

  def self.down
    drop_table :assignment_review_weights
  end
end
