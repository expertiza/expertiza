# OSS project_Team1 (jmfoste2) CSC517 Fall 2010
# Created to add logging functionality to the suggestion process

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
