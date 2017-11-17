class CreateResponseTimes < ActiveRecord::Migration
  def change
    create_table :response_times do |t|
      t.integer :map_id, presence: true
      t.string :link, presence: true
      t.integer :round, presence: true
      t.datetime :start_at, null: false
      t.datetime :end_at

      t.timestamps null: false
    end
  end
end
