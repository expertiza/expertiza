
class AddNewDeadlineType < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO `deadline_types` VALUES (12,'calibration_review');"
  end

  def self.down
    execute "DELETE FROM `deadline_types` WHERE `name` = 'calibration_review';"
  end
end