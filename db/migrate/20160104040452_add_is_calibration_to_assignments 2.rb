class AddIsCalibrationToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :is_calibrated, :boolean, default: false
  end
end
