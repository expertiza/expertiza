class CreateAwardedBadges < ActiveRecord::Migration[4.2]
  def change
    create_table :awarded_badges do |t|
      t.references :badge, index: true, foreign_key: true
      t.references :participant, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
