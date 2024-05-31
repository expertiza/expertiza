class CreateGradingHistories < ActiveRecord::Migration[5.1]
  def change
    unless table_exists?(:grading_histories)
      create_table :grading_histories do |t|
        t.integer :instructor_id
        t.integer :assignment_id
        t.string :grading_type
        t.integer :grade_receiver_id
        t.integer :grade
        t.text :comment
        t.timestamps
      end
    end
  end
end
