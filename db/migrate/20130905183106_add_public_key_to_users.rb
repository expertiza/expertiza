class AddPublicKeyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :public_key, :text
  end

  def self.down
    remove_column :users, :public_key
  end
end
