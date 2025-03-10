class DropQuizResponseTable < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :quiz_responses
  end

  def self.down; end
end
