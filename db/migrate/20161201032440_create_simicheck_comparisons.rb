class CreateSimicheckComparisons < ActiveRecord::Migration
  def change
    create_table :simicheck_comparisons do |t|
      t.string :comparison_key
      t.string :file_type


      t.references :assignment, foreign_key: {on_delete: :cascade}

      t.timestamps null: false
    end
  end
end
