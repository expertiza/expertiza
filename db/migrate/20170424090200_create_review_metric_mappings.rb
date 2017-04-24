class CreateReviewMetricMappings < ActiveRecord::Migration
  def change
    create_table :review_metric_mappings do |t|
      t.integer :metric_link
      t.integer :response_link
      t.integer :value

      t.references :review_metrics
      t.references :responses
      t.timestamps null: false
    end
  end
end
