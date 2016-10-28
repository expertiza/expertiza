class CreateMappingStrategies < ActiveRecord::Migration
  def self.up
  create_table "mapping_strategies", :force => true do |t|
    t.column "name", :string
  end
  
  execute "INSERT INTO `mapping_strategies` VALUES (1,'Static, pseudo-random');"
  
  end

  def self.down
    drop_table "mapping_strategies"
  end
end
