class CreateReviewMetrics < ActiveRecord::Migration
  def change
    create_table :review_metrics do |t|
      t.integer :response_id
      t.integer :volume
      t.boolean :suggestion
      t.boolean :problem
      t.boolean :offensive_term

      t.timestamps null: false
    end
  end
end
