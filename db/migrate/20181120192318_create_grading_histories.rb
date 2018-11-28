class CreateGradingHistories < ActiveRecord::Migration
  def change
    create_table :grading_histories do |t|
      t.integer :instructor_id
      t.integer :assignment_id
      t.string  :type
      t.integer :grade_receiver_id
      t.integer :grade
      t.text :comment
      t.timestamp :graded_at
      t.timestamps null: false
    end
  end
end
