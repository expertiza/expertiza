class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.int :team_id
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
