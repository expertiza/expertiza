class AddSimicheckRequiredToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :simicheck_required, :boolean, default: false
  end

  def self.down
    remove_column :assignments, :simicheck_required
  end
end
