class MenuUpdateBookmarks < ActiveRecord::Migration
  def self.up
    # get Permission entry
    permission1 = Permission.find(:first, :conditions=>["name = ?",'public actions - execute']);
    
    # is there already a sitecontroller for bookmarks?
    site_controller = SiteController.find_by_name(:first,:conditions=>["name = ?",'bookmarks'])
    # if not, create a bookmark
    if site_controller == nil
      site_controller = SiteController.create(:name => 'bookmarks', :permission_id => permission1.id, :builtin => 0)
    end
    # is there a view bookmarks action ?
    action1 = ControllerAction.find(:first, :conditions => ['name = "view_bookmarks" and site_controller_id = ?',site_controller.id])
    # if not, create an index action for leaderboard
    if action1 == nil
      action1 = ControllerAction.create(:name => 'view_bookmarks', :site_controller_id => site_controller.id)
    end
    action2 = ControllerAction.find(:first, :conditions => ['name = "manage_bookmarks" and site_controller_id = ?',site_controller.id])
    # if not, create an index action for leaderboard
    if action2 == nil
      action2 = ControllerAction.create(:name => 'manage_bookmarks', :site_controller_id => site_controller.id)
    end

    profileMenu = MenuItem.find_by_name(:first, :conditions =>["name = ?",'profile'])
    MenuItem.create(:name => 'bookmarks', :label => 'View Bookmarks', :parent_id => profileMenu, :seq => 1, :controller_action_id => action1.id)
    MenuItem.create(:name => 'bookmarks2', :label => 'Manage Bookmarks', :parent_id => profileMenu, :seq => 1, :controller_action_id => action2.id )

    
    Role.rebuild_cache
  end
  
  def self.down
    site_controller = SiteController.find_by_name('bookmarks')
    if site_controller 
      controllers = ControllerAction.find(:all, :conditions => ['site_controller_id = ?',site_controller.id])
      controllers.each {|controller|
        if controller 
          menuItem = MenuItem.find_by_controller_action_id(controller.id)
          if menuItem
            menuItem.destroy
          end       
            controller.destroy
        end
      }
      site_controller.destroy
    end
    # slide menu entries at sequence 11 or greater to the left 1 spot
    MenuItem.find(:all, :conditions => ['parent_id is null and seq >= 11']).each { |item|
      item.seq -= 1
      item.save
    }
    Role.rebuild_cache
  end
end
