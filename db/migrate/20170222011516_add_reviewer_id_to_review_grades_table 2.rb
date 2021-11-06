class AddReviewerIdToReviewGradesTable < ActiveRecord::Migration
  def change
  	add_column :review_grades, :reviewer_id, :integer
  end
end
