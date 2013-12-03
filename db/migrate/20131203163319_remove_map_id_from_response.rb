class RemoveMapIdFromResponse < ActiveRecord::Migration
  def self.up
    remove_column :responses, :map_id
  end

  def self.down
    add_column :responses, :map_id, :integer
  end
end
