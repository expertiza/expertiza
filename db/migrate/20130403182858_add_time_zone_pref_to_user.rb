class AddTimeZonePrefToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :timezonepref, :string
  end

  def self.down
    remove_column :users, :timezonepref
  end
end
