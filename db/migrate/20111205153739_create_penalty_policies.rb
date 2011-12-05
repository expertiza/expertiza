class CreatePenaltyPolicies < ActiveRecord::Migration
  def self.up
    create_table :penalty_policies do |t|
      t.integer :penalty_period_in_minutes
      t.float :penalty_unit_in_percentage
      t.float :max_sub_penalty
      t.float :max_rev_penalty
    end
    execute "INSERT INTO `penalty_policies` VALUES (1, 60, 0.25, 50, 10); "
  end

  def self.down
    drop_table :penalty_policies
  end
end
