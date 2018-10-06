class CreateEvidences < ActiveRecord::Migration
  def change
    create_table :evidences do |t|
      t.integer :awarded_badge_id
      t.string :file_name

      t.timestamps null: false
    end
  end
end
