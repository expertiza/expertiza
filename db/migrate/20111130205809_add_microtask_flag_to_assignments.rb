class AddMicrotaskFlagToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :microtask, :boolean, default: false
  end

  def self.down
    remove_column :assignments, :microtask
  end
end
