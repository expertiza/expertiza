class CreateAssignmentBadges < ActiveRecord::Migration
  def change
    create_table :assignment_badges do |t|
      t.references :badge, foreign_key: true
      t.references :assignment, foreign_key: true
      t.integer :threshold

      t.timestamps null: false
    end
  end
end
