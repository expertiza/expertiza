class AddSimicheckThresholdToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :simicheck_threshold, :integer, :default => 100
  end
end
