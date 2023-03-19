class AddAvailabilityFlagToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :availability_flag, :boolean
  end

  def self.down
    remove_column :assignments, :availability_flag
  end
end
