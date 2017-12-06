class InsertCalibrationDeadline < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO `deadline_types` VALUES (12,'calibration');"
  end
end
