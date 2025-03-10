class CreateReviewGradesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :review_grades do |t|
      t.integer :participant_id
      t.integer :grade_for_reviewer
      t.text :comment_for_reviewer
      t.datetime :review_graded_at
    end

    add_foreign_key :review_grades, :participants
  end
end
