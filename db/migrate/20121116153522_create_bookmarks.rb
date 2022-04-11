class CreateBookmarks < ActiveRecord::Migration[4.2]
  def self.up
    if table_exists?(:bookmarks) == false
      create_table :bookmarks do |t|
        t.column 'url', :string, null: false
        t.column 'discoverer_user_id', :integer, null: false
        t.column 'user_count', :integer, null: false

        t.timestamps
      end
    end
  end

  def self.down
    drop_table :bookmarks
  end
end
