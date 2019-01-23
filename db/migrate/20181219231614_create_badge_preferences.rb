class CreateBadgePreferences < ActiveRecord::Migration
  def change
    create_table :badge_preferences do |t|
      t.integer :instructor_id, limit: 11
      t.boolean :preference

      t.timestamps null: false
    end
  end
end
