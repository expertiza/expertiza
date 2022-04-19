class AddIsCalibrationToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :is_calibrated, :boolean, default: false
  end
end
