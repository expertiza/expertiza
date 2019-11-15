class CreateResponseTimes < ActiveRecord::Migration
  def change
    create_table :response_times do |t|

      t.timestamps null: false
    end
  end
end
