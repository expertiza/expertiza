class ChangeGradeForReviewerToFloat < ActiveRecord::Migration[5.1]
  def change
    change_column :review_grades, :grade_for_reviewer, :float
  end
end
