class AssignmentsAddColumns < ActiveRecord::Migration[4.2]

  def self.up
    add_column :assignments, :calculate_penalty, :boolean, null: false, default: FALSE
    add_column :assignments, :late_policy_id, :integer, null: true
    add_column :assignments, :is_penalty_calculated, :boolean, null: false, default: FALSE

    execute 'ALTER TABLE assignments ADD CONSTRAINT `fk_late_policy_id` FOREIGN KEY (late_policy_id) REFERENCES late_policies(id);'
  end

  def self.down
    execute 'ALTER TABLE assignments DROP FOREIGN KEY `fk_late_policy_id`;'

    remove_column :assignments, :calculate_penalty
    remove_column :assignments, :late_policy_id
    remove_column :assignments, :is_penalty_calculated
  end
end
