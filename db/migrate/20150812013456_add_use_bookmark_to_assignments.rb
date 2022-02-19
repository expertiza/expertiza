class AddUseBookmarkToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :use_bookmark, :boolean
  end
end
