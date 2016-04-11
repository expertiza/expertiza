class AddCredlyInUsersTable < ActiveRecord::Migration
  def self.up
    add_column :users, :credly_id, :integer
    add_column :users, :credly_accesstoken, :string
  end

  def self.down
    remove_column :users, :credly_id, :integer
    remove_column :users, :credly_accesstoken, :string
  end
end
