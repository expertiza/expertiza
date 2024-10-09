class RenameNameAndFullnameInUsers < ActiveRecord::Migration[5.1]
  def change
    # Renaming columns
    rename_column :users, :name, :username
    rename_column :users, :fullname, :name
  end
end