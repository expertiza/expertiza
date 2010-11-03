class CreateCategories < ActiveRecord::Migration
  def self.up
   create_table "categories", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
  end
   execute "INSERT INTO `categories` VALUES (100,'Other');"
   end
  def self.down
    drop_table "categories"
  end
end