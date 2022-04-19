class AddUseBookmarkToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :use_bookmark, :boolean
  end
end
