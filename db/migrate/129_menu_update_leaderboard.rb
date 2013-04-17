class MenuUpdateLeaderboard < ActiveRecord::Migration
  def self.up
    # get Permission entry
    permission1 = Permission.find_by_name('public actions - execute');
    
    # is there already a leaderboard?
    site_controller = SiteController.find_by_name('leaderboard')
    # if not, create a leaderboard
    if site_controller == nil
      site_controller = SiteController.create(:name => 'leaderboard', :permission_id => permission1.id, :builtin => 0)
    end
    # is there an index action for leaderboard?
    action = ControllerAction.find(:first, :conditions => ['name = "index" and site_controller_id = ?',site_controller.id])
    # if not, create an index action for leaderboard
    if action == nil
      action = ControllerAction.create(:name => 'index', :site_controller_id => site_controller.id)
    end
    # slide menu entries at sequence 10 or greater to the right 1 spot
    # WE'VE MOVED THE MENU UNDER PROFILE, SO THIS IS NOT NECESSARY
    # MenuItem.find(:all, :conditions => ['parent_id is null and seq >= 10']).each { |item|
    #  item.seq += 1
    #  item.save
    # }
    # insert menu item in the spot where we want
    profileMenu = MenuItem.find_by_name('profile')
    MenuItem.create(:name => 'leaderboard', :label => 'Leaderboard', :parent_id => profileMenu, :seq => 1, :controller_action_id => action.id)
    # find 'contact_us' and slide it over one spot.
    
    Role.rebuild_cache
  end
  
  def self.down
    site_controller = SiteController.find_by_name('leaderboard')
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
