class CreateSimilarAssignments < ActiveRecord::Migration
  def change
    create_table :similar_assignments do |t|
      t.integer :is_similar_for
      t.string :association_intent
      t.references :assignment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
