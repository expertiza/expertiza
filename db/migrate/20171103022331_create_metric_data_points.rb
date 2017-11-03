class CreateMetricDataPoints < ActiveRecord::Migration
  def change
    create_table :metric_data_points do |t|
      t.belongs_to :metric, index: true
      t.integer :metric_data_type_id, :null => false
      t.string :value

      t.timestamps null: false
    end
  end
end
