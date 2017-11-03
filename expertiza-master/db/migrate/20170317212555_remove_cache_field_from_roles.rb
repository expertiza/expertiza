class RemoveCacheFieldFromRoles < ActiveRecord::Migration
  def change
    remove_column :roles, :cache, :text
  end
end
