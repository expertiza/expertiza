class InsertSeccToHeaders < ActiveRecord::Migration
  def change
  end
  execute "INSERT INTO `site_controllers` VALUES (64,'student_quiz',8,0)"
  execute "INSERT INTO `site_controllers` VALUES (65,'sections',7,0)"
  execute "INSERT INTO `controller_actions` VALUES (110,65,'index',7,'')"
end
