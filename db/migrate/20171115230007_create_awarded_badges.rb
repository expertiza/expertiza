class CreateAwardedBadges < ActiveRecord::Migration
  def change
    create_table :awarded_badges do |t|
      t.references :badge, foreign_key: true
      t.references :participant, foreign_key: true

      t.timestamps null: false
    end
  end
end
