class CreateDeadlineTypes < ActiveRecord::Migration
  def self.up
  create_table "deadline_types", :force => true do |t|
    t.column "name", :string, :limit => 32
  end
  
  execute "INSERT INTO `deadline_types` VALUES (1,'submission'),(2,'review'),(3,'resubmission'),(4,'rereview'),(5,'review of review');"
  
  end

  def self.down
    drop_table "deadline_types"
  end
end
