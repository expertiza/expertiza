class CreateDuties < ActiveRecord::Migration
  def change
    create_table :duties do |t|
      t.string :name, :null => false, :unique => true
      t.boolean :allow_multiple_duties, :default => false

      t.timestamps null: false
    end
  end
end
