class AddMicrotaskFlagToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :microtask, :boolean, :default => false
  end

  def self.down
    remove_column :assignments, :microtask
  end
end
