class IncreaseSessionStore < ActiveRecord::Migration
  def self.up
    change_column :sessions, :data, :text, :limit => 4.megabytes
  end

  def self.down
  end
end
