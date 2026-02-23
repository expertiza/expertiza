class CreateResponseGrades < ActiveRecord::Migration[5.1]
  def change
    create_table :instructor_response_scores do |t|
      t.integer :response_id, null: false
      t.integer :score
      t.text :feedback
      t.timestamps
    end

    add_index :instructor_response_scores, :response_id, unique: true
    add_foreign_key :instructor_response_scores, :responses, column: :response_id
  end
end
