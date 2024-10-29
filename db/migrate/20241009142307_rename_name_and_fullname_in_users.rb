class RenameNameAndFullnameInUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :name, :username
    rename_column :account_requests, :name, :username
    rename_column :users, :fullname, :name
    rename_column :account_requests, :fullname, :username
  end
end