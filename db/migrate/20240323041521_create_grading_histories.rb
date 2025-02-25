class CreateGradingHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :grading_histories do |t|
      t.integer :instructor_id
      t.integer :assignment_id
      t.string :graded_item_type
      t.integer :graded_member_id
      t.integer :grade
      t.text :comment

      t.timestamps null: false
    end
  end
end
