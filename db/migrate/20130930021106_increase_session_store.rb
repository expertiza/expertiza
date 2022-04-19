class IncreaseSessionStore < ActiveRecord::Migration[4.2]
  def self.up
    change_column :sessions, :data, :text, limit: 4.megabytes
  end

  def self.down; end
end
