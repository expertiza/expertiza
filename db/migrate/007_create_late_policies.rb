class CreateLatePolicies < ActiveRecord::Migration
  def self.up
  create_table "late_policies", :force => true do |t|
    t.column "penalty_period_in_minutes", :integer
    t.column "penalty_per_unit", :integer
    t.column "expressed_as_percentage", :boolean
    t.column "max_penalty", :integer, :default => 0, :null => false
  end

  add_index "late_policies", ["penalty_period_in_minutes"], :name => "penalty_period_length_unit"

  end

  def self.down
    drop_table "late_policies"
  end
end
