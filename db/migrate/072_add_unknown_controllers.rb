class AddUnknownControllers < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('do assignments')
    controller = SiteController.find_or_create_by(name: 'student_team')
    controller.permission_id = permission.id
    controller.save
    
    controller = SiteController.find_or_create_by(name: 'invitation')
    controller.permission_id = permission.id
    controller.save  
    
    permission = Permission.find_by_name('administer assignments')
    controller = SiteController.find_or_create_by(name: 'survey')
    controller.permission_id = permission.id
    controller.save     
  end

  def self.down
  end
end
