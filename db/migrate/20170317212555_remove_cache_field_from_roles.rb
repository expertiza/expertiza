class RemoveCacheFieldFromRoles < ActiveRecord::Migration[4.2]
  def change
    remove_column :roles, :cache, :text
  end
end
