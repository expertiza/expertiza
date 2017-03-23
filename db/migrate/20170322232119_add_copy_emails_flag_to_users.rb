class AddCopyEmailsFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :copy_emails, :boolean
  end
end
