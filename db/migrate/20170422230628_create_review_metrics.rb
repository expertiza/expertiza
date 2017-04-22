class CreateReviewMetrics < ActiveRecord::Migration
  def change
    create_table :review_metrics do |t|
      t.string :metric

      t.timestamps null: false
    end
  end
end
