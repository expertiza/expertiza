class AddPermissionUpdatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :permission_updated_at, :datetime
  end

  def self.down
    remove_column :users, :permission_updated_at
  end
end
