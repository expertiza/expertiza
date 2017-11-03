class CreateMetricDataPoints < ActiveRecord::Migration
  def change
    create_table :metric_data_points do |t|
      t.belongs_to :metric, index: true
      t.belongs_to :metric_data_point_type
      t.string :value

      t.timestamps null: false
    end
  end
end
