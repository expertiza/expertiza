class CreateBmappingTags < ActiveRecord::Migration[4.2]
  def self.up
    if table_exists?(:bmappings_tags) == false
      create_table :bmappings_tags do |t|
        t.column 'tag_id', :integer, null: false
        t.column 'bmapping_id', :integer, null: false
        t.timestamps
      end
      end
  end

  def self.down
    drop_table :bmappings_tags
  end
end
