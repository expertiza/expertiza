class CreateSamplereviewmaps < ActiveRecord::Migration
  def change
    create_table :samplereviewmaps do |t|
      t.integer :response_map_id
      t.integer :assignment_id

      t.timestamps null: false
    end
  end
end
