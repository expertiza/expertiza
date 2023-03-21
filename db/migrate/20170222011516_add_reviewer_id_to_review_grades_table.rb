class AddReviewerIdToReviewGradesTable < ActiveRecord::Migration[4.2]
  def change
    add_column :review_grades, :reviewer_id, :integer
  end
end
