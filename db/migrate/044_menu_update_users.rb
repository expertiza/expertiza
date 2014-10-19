class MenuUpdateUsers < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('administer assignments')
    if permission != nil
      site_controller = SiteController.find_by_name('users')
      if site_controller != nil  
        action = ControllerAction.where(:site_controller_id=>site_controller.id, :name=>'list').first
        if action != nil
          action.permission_id = permission.id   
          action.save
        end      
      end
      page = ContentPage.find_by_name('site_admin')
      if page != nil
        page.permission_id = permission.id
        page.save
      end
      page = ContentPage.find_by_name('admin')
      if page != nil
        page.permission_id = permission.id
        page.save
      end
    end
    Role.rebuild_cache
  end

  def self.down
    site_controller = SiteController.find_by_name('users')
    if site_controller != nil
        action = ControllerAction.where(:site_controller_id=>site_controller.id, :name=>'list').first
      if action != nil
        action.permission_id = nil
        action.save
      end
    end
    
    Role.rebuild_cache
  end
end
