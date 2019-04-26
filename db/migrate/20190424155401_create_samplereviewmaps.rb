class CreateSamplereviewmaps < ActiveRecord::Migration
  def change
    create_table :samplereviewmaps do |t|
      t.references :response_map, foreign_key: true
      t.references :assignment, foreign_key: true
      t.timestamps null: false
    end
  end
end
