class CreateMetricDataPointTypes < ActiveRecord::Migration
  def self.up
    create_table :metric_data_point_types do |t|
      t.string :name
      t.integer :source
      t.string :value_type
      t.string :description
      t.integer :dimension

      t.timestamps null: false

      t.index :name, :unique => true
    end

    MetricDataPointType.create :name => "commit_id", :source => MetricDataPointType.sources["github"], :value_type => "string", 
      :description => "Commit Id", :dimension => "label"
    MetricDataPointType.create :name => "user_id", :source => MetricDataPointType.sources["github"], :value_type => "string", 
      :description => "User Id", :dimension => "label"
    MetricDataPointType.create :name => "user_name", :source => MetricDataPointType.sources["github"], :value_type => "string", 
      :description => "User Name", :dimension => "label"
    MetricDataPointType.create :name => "user_email", :source => MetricDataPointType.sources["github"], :value_type => "string", 
      :description => "User Email", :dimension => "label"
    MetricDataPointType.create :name => "commit_date", :source => MetricDataPointType.sources["github"], :value_type => "datetime",      
      :description => "Commit Date", :dimension => "x"
    MetricDataPointType.create :name => "lines_added", :source => MetricDataPointType.sources["github"], :value_type => "int", 
      :description  => "Number of lines added", :dimension => "y"
    MetricDataPointType.create :name => "lines_deleted", :source => MetricDataPointType.sources["github"], :value_type => "int", 
      :description  => "Number of lines deleted", :dimension => "y"
    MetricDataPointType.create :name => "lines_changed", :source => MetricDataPointType.sources["github"], :value_type => "int", 
      :description  => "Number of lines changed total", :dimension => "y"
  end

  def self.down
    drop_table :metric_data_point_types
  end
end
