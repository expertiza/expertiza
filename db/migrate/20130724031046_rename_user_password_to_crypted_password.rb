class RenameUserPasswordToCryptedPassword < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :users, :password, :crypted_password
  end

  def self.down
    rename_column :users, :crypted_password, :password
  end
end
