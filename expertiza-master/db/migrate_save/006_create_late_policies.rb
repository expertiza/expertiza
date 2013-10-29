class CreateLatePolicies < ActiveRecord::Migration
  def self.up
    create_table :late_policies do |t|
      # t.column :name, :string
        t.column :penalty_period_in_minutes, :integer  # length of penalty period, expressed in minutes; e.g., if penalty is per hour, value here is 60
	t.column :penalty_per_unit, :integer # how many points or how many percent deducted for each unit (above) late
	t.column :expressed_as_percentage, :boolean # if false, then penalty is expressed in (absolute) points
    t.column :max_penalty, :integer # the maximum penalty for not doing the work for this deadline; a value of 0 here means that the maximum penalty is a score of 0 on the assignment; a negative value means that the penalty is unlimited
    end
  end

  def self.down
    drop_table :late_policies
  end
end
