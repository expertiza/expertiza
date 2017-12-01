class AddWikiIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wiki_id, :integer
  end
end
