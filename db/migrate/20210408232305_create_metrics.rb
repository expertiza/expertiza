class CreateMetrics < ActiveRecord::Migration
  def up
    create_table :metrics do |t|
      t.integer :metric_source_id

      t.timestamps null: false
    end
    Metric.create :metric_source_id => MetricSource.find_by_name("Github").id
    Metric.create :metric_source_id => MetricSource.find_by_name("TravisCI").id
  end
  def down
    drop_table :metrics
  end
end
