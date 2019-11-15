class CreateResponseTimes < ActiveRecord::Migration

  def change
    create_table :response_times do |t|
      t.integer :map_id
      t.string :link
      t.integer :round
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps null: false
    end
  end
end