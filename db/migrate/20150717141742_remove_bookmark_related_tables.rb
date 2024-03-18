class RemoveBookmarkRelatedTables < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :books
    drop_table :bmappings
    drop_table :bmapping_ratings
    drop_table :bookmarks
    drop_table :bmappings_tags
    drop_table :bookmark_rating_rubrics
    drop_table :bookmark_tags
    drop_table :bmappings_sign_up_topics
  end
end
