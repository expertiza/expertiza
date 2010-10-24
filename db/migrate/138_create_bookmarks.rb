class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.column "url", :string, :null => false
      t.column "discoverer_user_id", :integer, :null=> false
      t.column "user_count", :integer, :null => false

    end
  end

  def self.down
    drop_table :bookmarks
  end
end
