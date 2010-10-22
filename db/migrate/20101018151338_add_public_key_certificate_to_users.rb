class AddPublicKeyCertificateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :public_key, :text, :limit => 500
    add_column :users, :certificate, :text, :limit => 1000
  end

  def self.down
    remove_column :users, :certificate
    remove_column :users, :public_key
  end
end
