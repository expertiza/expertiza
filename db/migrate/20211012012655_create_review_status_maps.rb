class CreateReviewStatusMaps < ActiveRecord::Migration
  def change
    create_table :review_status_maps do |t|
      t.integer :reviewee_id
      t.integer :reviewer_id
      t.string :status
      t.integer :review_object_id

      t.timestamps null: false
    end
  end
end
