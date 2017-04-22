class CreateReviewMetrics < ActiveRecord::Migration
  def change
    create_table :review_metrics do |t|
      t.integer :metric

      t.timestamps null: false
    end
  end
end
