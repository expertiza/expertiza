class SetDefaultPriorityInSignedUpUser < ActiveRecord::Migration
  def self.up
    change_column :signed_up_users, :preference_priority_number, :integer, :default => 0
  end

  def self.down
    change_column :signed_up_users, :preference_priority_number, :integer
  end
end
