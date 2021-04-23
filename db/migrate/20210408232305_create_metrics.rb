class CreateMetrics < ActiveRecord::Migration
  def up
    create_table :metrics do |t|
      t.integer :metric_source_id
      t.integer :team_id
      t.string :github_id
      t.integer :participant_id
      t.integer :total_commits
      t.timestamps null: false
    end
    add_column :users, :github_id, :string
    # Metric.create :metric_source_id => MetricSource.find_by_name("Github").id
    #Metric.create :metric_source_id => MetricSource.find_by_name("TravisCI").id
  end
  def down
    drop_table :metrics
    remove_column :users, :github_id
  end
end
