class CreateMetareviewScores < ActiveRecord::Migration
  def change
    create_table :metareview_scores do |t|
      t.integer :review_id
      t.integer :volume
      t.float :tone_negative
      t.float :tone_positive
      t.float :tone_neutral
      t.float :advisory
      t.float :problem_identification
      t.float :summative
      t.float :relevance
      t.float :coverage
      t.binary :plagiarism
      t.datetime :last_updated
      t.timestamps null: false
    end
  end
end
