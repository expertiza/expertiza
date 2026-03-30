class UpdateInstructorReviewScoresForFormativeAndSummative < ActiveRecord::Migration[5.1]
  def change
    rename_column :instructor_review_scores, :score, :score_for_summative
    rename_column :instructor_review_scores, :feedback, :feedback_for_formative

    add_column :instructor_review_scores, :score_for_formative, :float
    add_column :instructor_review_scores, :feedback_for_summative, :text
  end
end
