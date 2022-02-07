class RemoveLatePolicyDueDate < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE due_dates DROP FOREIGN KEY `fk_due_date_late_policies`;"
    remove_column :due_dates, :late_policy_id
  end

  def self.down
    add_column :due_dates, :late_policy_id, :integer
    execute "ALTER TABLE due_dates ADD CONSTRAINT `fk_due_date_late_policies` FOREIGN KEY (late_policy_id) REFERENCES late_policies(id);"
  end
end
