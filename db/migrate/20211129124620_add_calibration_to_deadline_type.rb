class AddCalibrationToDeadlineType < ActiveRecord::Migration
  def self.up
    DeadlineType.create :name => "calibration"
  end

  def self.down
    DeadlineType.find_by_name("calibration").destroy
  end
end
