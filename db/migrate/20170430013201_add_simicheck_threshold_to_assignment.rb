class AddSimicheckThresholdToAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :simicheck_threshold, :integer, default: 100
  end
end
