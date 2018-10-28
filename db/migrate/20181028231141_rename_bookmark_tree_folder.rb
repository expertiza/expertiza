class RenameBookmarkTreeFolder < ActiveRecord::Migration
  def change
    execute "UPDATE tree_folders SET name = 'BookmarkRating' WHERE id = 11"
  end
end
