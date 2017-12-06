class CreateBadgeNominations < ActiveRecord::Migration
  def change
    create_table :badge_nominations do |t|
      t.references :assignment, index: true, foreign_key: true
      t.references :participant, index: true, foreign_key: true
      t.references :badge, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
