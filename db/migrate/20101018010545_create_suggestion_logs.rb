class CreateSuggestionLogs < ActiveRecord::Migration
  def self.up
    create_table :suggestion_logs do |t|
      t.integer :user_id
      t.integer :suggestion_id
      t.timestamps
    end
  end

  def self.down
    drop_table :suggestion_logs
  end
end
