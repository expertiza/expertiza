class CreateSampleReviews < ActiveRecord::Migration
  def change
    create_table :sample_reviews do |t|

      t.integer :assignment_id
      t.integer :response_id

      t.timestamps null: false
    end

  end
end
