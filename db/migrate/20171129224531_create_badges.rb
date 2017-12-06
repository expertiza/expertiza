class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.text :name
      t.text :description

      t.timestamps null: false
    end
  end
end
