class UpdateBookmarkRatingTreeFolderRating < ActiveRecord::Migration
  def change
	execute "UPDATE tree_folders set name = 'Bookmark Rating' where name in ('Bookmarkrating')"
  end
end
