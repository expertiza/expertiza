class AddCopyOfEmailsFlagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :copy_of_emails, :boolean, :default => false
  end

  def self.down
    remove_column :users, :copy_of_emails
  end
end

