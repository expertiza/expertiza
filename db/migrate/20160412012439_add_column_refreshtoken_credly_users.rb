class AddColumnRefreshtokenCredlyUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :credly_refreshtoken, :string
  end

  def self.down
    remove_column :users, :credly_refreshtoken, :string
  end
end
