class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
    	t.column "tagname", :string, :null=> false
    end
  end

  def self.down
    drop_table :tags
  end
end

