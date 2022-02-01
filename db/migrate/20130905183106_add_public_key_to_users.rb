class AddPublicKeyToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :public_key, :text
  end

  def self.down
    remove_column :users, :public_key
  end
end
