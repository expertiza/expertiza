class CreateNominations < ActiveRecord::Migration
  def change
    create_table :nominations do |t|
      t.integer :assignment_badge_id
      t.integer :recipient_id
      t.integer :nominator_id

      t.timestamps null: false
    end
  end
end
