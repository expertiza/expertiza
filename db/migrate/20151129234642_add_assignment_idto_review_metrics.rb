class AddAssignmentIdtoReviewMetrics < ActiveRecord::Migration
  def change
	add_column :review_metrics, :assignment_id, :integer
	add_foreign_key :review_metrics, :assignments
  end
end
