class AddCopyFlagToAssignments < ActiveRecord::Migration[4.2]
  def self.up
    add_column :assignments, :copy_flag, :boolean, default: false
  end

  def self.down
    remove_column :assignments, :copy_flag
  end
end
