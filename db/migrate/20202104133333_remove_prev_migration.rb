class RemovewPrevMigration < ActiveRecord::Migration
  def change
    remove_column :assignments, :metareview_enabled
  end
end