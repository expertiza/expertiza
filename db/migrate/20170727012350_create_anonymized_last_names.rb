class CreateAnonymizedLastNames < ActiveRecord::Migration
  def change
    create_table :anonymized_last_names do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
