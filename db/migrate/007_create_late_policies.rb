class CreateLatePolicies < ActiveRecord::Migration
  def self.up
  create_table "late_policies", :force => true do |t|
    t.column "penalty_period_in_minutes", :integer
    t.column "penalty_per_unit", :integer
    t.column "expressed_as_percentage", :boolean
    t.column "max_penalty", :integer, :default => 0, :null => false
  end

  add_index "late_policies", ["penalty_period_in_minutes"], :name => "penalty_period_length_unit"

  execute "INSERT INTO `late_policies` VALUES (1,30,1,NULL,20),(2,60,1,NULL,20),(3,90,1,NULL,20),(4,120,1,NULL,20);"

  end

  def self.down
    drop_table "late_policies"
  end
end
