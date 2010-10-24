class CreateQualifiers< ActiveRecord::Migration
  def self.up
    create_table :qualifiers do |t|
    	t.column "tag_id", :integer, :null=> false
    	t.column "bmapping_id", :integer, :null => false
    end
  end

  def self.down
    drop_table :qualifiers
  end
end
