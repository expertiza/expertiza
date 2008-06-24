class UpdateForCopy < ActiveRecord::Migration
  def self.up
     permission1 = Permission.find_by_name('administer assignments');
     site_controller = SiteController.create(:name => 'copy', :permission_id => permission1.id, :builtin => 0)
     Role.rebuild_cache
  end

  def self.down
    site_controller = SiteController.find_by_name('copy')
    if site_controller 
       site_controller.destroy
       Role.rebuild_cache
    end
  end
end
