class RemoveGradesCommentsForReviewerAndReviewTimeFromParticipantsTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :participants, :grade_for_reviewer
    remove_column :participants, :comment_for_reviewer
    remove_column :participants, :review_graded_at
  end
end
