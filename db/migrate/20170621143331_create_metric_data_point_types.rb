class CreateMetricDataPointTypes < ActiveRecord::Migration
  def change
    create_table :metric_data_point_types do |t|
      t.string :name
      t.string :value_type
      t.name :description
      t.string :dimension

      t.timestamps null: false
    end
  end
end
