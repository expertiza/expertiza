class RemoveCacheFromRoles < ActiveRecord::Migration
  def change
    remove_column :roles,:cache
  end
end
