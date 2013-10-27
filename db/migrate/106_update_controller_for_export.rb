class UpdateControllerForExport < ActiveRecord::Migration
  def self.up
    perm = Permission.find_by_name("administer assignments")
    controller = SiteController.find_or_create_by_name("export_file")
    controller.permission_id = perm.id
    controller.save
    
    Role.rebuild_cache 
  end

  def self.down
  end
end
