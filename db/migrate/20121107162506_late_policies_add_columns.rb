class LatePoliciesAddColumns < ActiveRecord::Migration

  def self.up
    add_column :late_policies, :times_used, :integer, :null => false, :default => 0
    add_column :late_policies, :instructor_id, :integer
    add_column :late_policies, :policy_name, :string

    execute "ALTER TABLE late_policies ADD CONSTRAINT `fk_instructor_id` FOREIGN KEY (instructor_id) REFERENCES users(id);"

    remove_column :late_policies, :expressed_as_percentage
    remove_column :late_policies, :penalty_period_in_minutes
  end

  def self.down
    execute "ALTER TABLE late_policies DROP CONSTRAINT `fk_instructor_id`;"

    remove_column :late_policies, :times_used
    remove_column :late_policies, :instructor_id
    remove_column :late_policies, :policy_name

    add_column :late_policies, :expressed_as_percentage, :boolean
    add_column :late_policies, :penalty_period_in_minutes, :integer
  end
end
