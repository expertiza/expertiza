class CreateDuties < ActiveRecord::Migration[4.2]
  def change
    create_table :duties do |t|
      t.string :name
      t.integer :max_duty_limit
      t.references :assignment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
