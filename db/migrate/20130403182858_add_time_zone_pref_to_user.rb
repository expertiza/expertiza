class AddTimeZonePrefToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :timezonepref, :string
  end

  def self.down
    remove_column :users, :timezonepref
  end
end
