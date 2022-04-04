class CreateNotificationsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.string :subject
      t.text :description
      t.date :expiration_date
      t.boolean :active_flag
      t.timestamps null: false
    end
  end
end
