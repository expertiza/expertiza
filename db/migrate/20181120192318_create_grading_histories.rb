class CreateGradingHistories < ActiveRecord::Migration
  def change
    create_table :grading_histories do |t|
      t.integer :instructor_id
      t.integer :assignment_id
      t.string :grade_type
      t.integer :student_id
      t.double :grade
      t.text :comment
      t.timestamp :timestamp

      t.timestamps null: false
    end
  end
end
