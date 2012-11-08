class AssignmentsAddColumns < ActiveRecord::Migration

  def self.up
    add_column :assignments, :calculate_penalty, :boolean, :null => false, :default => FALSE
    add_column :assignments, :late_policy_id, :integer

    execute "ALTER TABLE assignments ADD CONSTRAINT `late_policy_id` FOREIGN KEY (late_policy_id) REFERENCES late_policies(id);"
  end

  def self.down
    execute "ALTER TABLE assignments DROP CONSTRAINT `late_policy_id`;"

    remove_column :assignments, :calculate_penalty
    remove_column :assignments, :late_policy_id
  end
end
