class RenameNameAndFullnameInUsers < ActiveRecord::Migration[5.1]
  def change
    # Renaming columns
    rename_column :users, :name, :username
    rename_column :account_requests, :name, :username
  end
end