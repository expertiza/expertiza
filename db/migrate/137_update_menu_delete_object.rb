class UpdateMenuDeleteObject < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name("administer assignments")
    
    site_controller = SiteController.create(:name => "delete_object", :permission_id => permission.id)
             
    Role.rebuild_cache     
  end

  def self.down
  end
end
