class CreateLocalDbScores < ActiveRecord::Migration
  def self.up
    create_table :local_db_scores do |t|

      t.string :score_type
      t.integer :round
      t.integer :score
      t.references :response_map, index: true, foreign_key: true

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :local_db_scores
  end
end
