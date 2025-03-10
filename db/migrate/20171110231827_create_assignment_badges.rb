class CreateAssignmentBadges < ActiveRecord::Migration[4.2]
  def change
    create_table :assignment_badges do |t|
      t.references :badge, index: true, foreign_key: true
      t.references :assignment, index: true, foreign_key: true
      t.integer :threshold
      t.timestamps null: false
    end
  end
end
