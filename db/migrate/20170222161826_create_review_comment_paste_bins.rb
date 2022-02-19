class CreateReviewCommentPasteBins < ActiveRecord::Migration[4.2]
  def change
    create_table :review_comment_paste_bins do |t|
      t.integer :review_grade_id
      t.string :title
      t.text :review_comment
      t.timestamps null: false
    end

    add_foreign_key :review_comment_paste_bins, :review_grades
  end
end
