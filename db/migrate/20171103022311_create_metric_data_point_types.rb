class CreateMetricDataPointTypes < ActiveRecord::Migration
  def self.up
    create_table :metric_data_point_types do |t|
      t.string :name
      t.string :value_type
      t.string :description
      t.integer :dimension

      t.timestamps null: false

      t.index :name, :unique => true
    end

    MetricDataPointType.create :name => "commit_id", :value_type => "string", 
      :description => "Commit Id", :dimension => "label"
    MetricDataPointType.create :name => "user_id", :value_type => "string", 
      :description => "User Id", :dimension => "label"
    MetricDataPointType.create :name => "user_name", :value_type => "string", 
      :description => "User Name", :dimension => "label"
    MetricDataPointType.create :name => "user_email", :value_type => "string", 
      :description => "User Email", :dimension => "label"
    MetricDataPointType.create :name => "commit_date", :value_type => "datetime",      
      :description => "Commit Date", :dimension => "x"
    MetricDataPointType.create :name => "lines_added", :value_type => "int", 
      :description  => "Number of lines added", :dimension => "y"
    MetricDataPointType.create :name => "lines_deleted", :value_type => "int", 
      :description  => "Number of lines deleted", :dimension => "y"
    MetricDataPointType.create :name => "lines_changed", :value_type => "int", 
      :description  => "Number of lines changed total", :dimension => "y"
  end

  def self.down
    drop_table :metric_data_point_types
  end
end
