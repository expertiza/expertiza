class AddAvailabilityFlagToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :availability_flag, :boolean
  end

  def self.down
    remove_column :assignments, :availability_flag
  end
end
