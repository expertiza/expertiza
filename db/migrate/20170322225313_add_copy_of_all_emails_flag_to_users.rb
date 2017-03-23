class AddCopyOfAllEmailsFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :copy_of_all_emails, :boolean
  end
end
