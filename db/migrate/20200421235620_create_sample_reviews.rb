class CreateSampleReviews < ActiveRecord::Migration[4.2]
  def change
    create_table :sample_reviews, id: :integer, auto_increment: true do |t|
      t.integer :assignment_id
      t.integer :response_id

      t.timestamps null: false
    end
  end
end
