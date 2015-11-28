class CreateReviewMetrics < ActiveRecord::Migration
  def change
    create_table :review_metrics do |t|
      t.integer :response_id
      t.integer :total_word_count
      t.integer :diff_word_count
      t.integer :suggestion_count
      t.integer :error_count
      t.integer :offensive_count
      t.integer :complete_count

      t.timestamps null: false
    end
    add_foreign_key :review_metrics, :responses
  end
end
