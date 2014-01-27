class DropQuizResponseTable < ActiveRecord::Migration
  def self.up
    drop_table :quiz_responses
  end

  def self.down
  end
end
