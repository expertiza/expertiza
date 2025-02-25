class CreateBmappings < ActiveRecord::Migration[4.2]
  def self.up
    if table_exists?(:bmappings) == false
      create_table :bmappings do |t|
        t.column 'bookmark_id', :integer, null: false
        t.column 'title', :string
        t.column 'user_id', :integer, null: false
        t.column 'description', :string
        t.column 'date_created', :datetime, null: false
        t.column 'date_modified', :datetime, null: false
        #### rich join between bookmarks and users ####
      end
      end
  end

  def self.down
    drop_table :bmappings
  end
end
