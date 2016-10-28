class CreateDeadlineRights < ActiveRecord::Migration
  def self.up
  create_table "deadline_rights", :force => true do |t|
    t.column "name", :string, :limit => 32
  end
   
  execute "INSERT INTO `deadline_rights` VALUES (1,'No'),(2,'Late'),(3,'OK');"
  
  end

  def self.down
    drop_table "deadline_rights"
  end
end
