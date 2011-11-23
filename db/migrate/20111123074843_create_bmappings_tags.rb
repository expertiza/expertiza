class CreateBmappingsTags < ActiveRecord::Migration
  def self.up
    create_table :bmappings_tags do |t|
      t.column "tag_id", :integer, :null=> false
      t.column "bmapping_id", :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :bmappings_tags
  end
end
