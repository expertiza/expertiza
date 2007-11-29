class CreateWikiTypes < ActiveRecord::Migration
  def self.up
    create_table :wiki_types do |t|
      t.column :name, :string #Wiki Assignment Type
    end
    wiki_type = WikiType.create(:name=>"No")
    wiki_type.save
    wiki_type = WikiType.create(:name=>"MediaWiki")
    wiki_type.save
    wiki_type = WikiType.create(:name=>"DokuWiki")
    wiki_type.save
  end
  
  def self.down
    drop_table :wiki_types
  end
end
