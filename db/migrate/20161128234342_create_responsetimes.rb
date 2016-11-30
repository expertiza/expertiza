class CreateResponsetimes < ActiveRecord::Migration
  def change
    create_table :responsetimes do |t|
      t.integer :map_id
      t.integer :round
      t.string :link
      t.datetime :start

      t.timestamps null: false
    end
  end
end
