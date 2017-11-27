
class AddNewDeadlineType < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO `deadline_types` VALUES (6,'calibration review');"
  end

  def self.down
    execute "DELETE FROM `deadline_types` WHERE `name` = 'calibration review';"
  end
end