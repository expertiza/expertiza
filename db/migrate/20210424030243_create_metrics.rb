class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|

      t.timestamps null: false
    end
  end
end
