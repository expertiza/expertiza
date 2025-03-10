class UpdateTreeFolderTable < ActiveRecord::Migration[4.2]
  def up
    tree_folder = TreeFolder.find_by_id(11)
    tree_folder.name = 'Bookmark Rating'
    tree_folder.save
  end

  def down
    tree_folder = TreeFolder.find_by_id(11)
    tree_folder.name = 'Bookmarkrating'
    tree_folder.save
  end
end
