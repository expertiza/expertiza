class CreateLocalDbScores < ActiveRecord::Migration
  def change
    create_table :local_db_scores do |t|
      t.string :type
      t.integer :round
      t.integer :score
      t.references :response_map, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
