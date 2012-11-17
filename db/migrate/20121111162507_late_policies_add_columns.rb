class LatePoliciesAddColumns < ActiveRecord::Migration

  def self.up

    change_column :late_policies, :penalty_per_unit, :float

    add_column :late_policies, :times_used, :integer, :null => false, :default => 0
    add_column :late_policies, :instructor_id, :integer, :null => false
    add_column :late_policies, :policy_name, :string, :null => false

    execute "ALTER TABLE late_policies ADD CONSTRAINT `fk_instructor_id` FOREIGN KEY (instructor_id) REFERENCES users(id);"

    remove_index "late_policies"

    remove_column :late_policies, :expressed_as_percentage
    remove_column :late_policies, :penalty_period_in_minutes

  end

  def self.down

    add_column :late_policies, :expressed_as_percentage, :boolean
    add_column :late_policies, :penalty_period_in_minutes, :integer

    add_index "late_policies", ["penalty_period_in_minutes"], :name => "penalty_period_length_unit"

    execute "ALTER TABLE late_policies DROP FOREIGN KEY `fk_instructor_id`;"

    remove_column :late_policies, :times_used
    remove_column :late_policies, :instructor_id
    remove_column :late_policies, :policy_name

    change_column :late_policies, :penalty_per_unit, :integer

  end
end
