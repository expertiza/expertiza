class CreateAssignmentWeights < ActiveRecord::Migration
  def self.up
    create_table :assignment_weights do |t|
      t.integer :assignment_id
      t.integer :topic_id
      t.float :weight

      t.timestamps
    end
  end

  def self.down
    drop_table :assignment_weights
  end
end
