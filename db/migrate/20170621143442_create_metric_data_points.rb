class CreateMetricDataPoints < ActiveRecord::Migration
  def change
    create_table :metric_data_points do |t|
      t.integer :metric_id
      t.integer :metric_data_type_id
      t.string :value

      t.timestamps null: false
    end
  end
end
