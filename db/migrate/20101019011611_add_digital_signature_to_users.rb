class AddDigitalSignatureToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :digital_signature, :text
  end

  def self.down
    remove_column :users, :digital_signature
  end
end
