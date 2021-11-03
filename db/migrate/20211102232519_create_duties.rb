class CreateDuties < ActiveRecord::Migration
  def change
    create_table :duties do |t|
      t.string :duty_name
      t.integer :max_duty_limit
      t.references :assignment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
