class CreateReviewMetricsMappings < ActiveRecord::Migration
  def change
    create_table :review_metrics_mappings do |t|
      t.integer :response
      t.integer :metric
      t.integer :value

      t.timestamps null: false
    end
  end
end
