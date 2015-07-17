class CreateBookmarksTableAndBookmarkRatingsTable < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
    	t.text :url
    	t.text :title
    	t.text :description
    	t.references :user
    	t.references :topic
    	t.timestamps
    end
    add_index :bookmarks, :topic_id

    create_table :bookmark_ratings do |t|
    	t.references :bookmark
    	t.references :user
    	t.integer :rating
    	t.timestamps
    end
  end

  def self.down
  	drop_table :bookmark_ratings
  	drop_table :bookmarks
  end

end
