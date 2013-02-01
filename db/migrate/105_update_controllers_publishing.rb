class UpdateControllersPublishing < ActiveRecord::Migration
  def self.up
    perm = Permission.find_by_name("do assignments")
    
    controller = SiteController.find_or_create_by_name("publishing")
    controller.permission_id = perm.id
    controller.save      
    
    Role.rebuild_cache
  end

  def self.down
  end
end
