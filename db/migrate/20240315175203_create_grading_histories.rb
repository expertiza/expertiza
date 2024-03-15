class CreateGradingHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :grading_histories do |t|
      t.string :grading_type
      t.integer :grade
      t.text :comment

      t.timestamps
    end
  end
end
