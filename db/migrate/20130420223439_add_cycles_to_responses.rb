class AddCyclesToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :cycle, :integer, :default => 0
  end

  def self.down
    remove_column :responses, :cycle
  end
end
