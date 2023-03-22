class CreateMetricSources < ActiveRecord::Migration[4.2]
  def up
    create_table :metric_sources do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
    MetricSource.create :name => "Github", :description => "CVS Hosting"
    MetricSource.create :name => "TravisCI", :description => "Build Tool"
  end
  def down
    drop_table :metric_sources
  end
end