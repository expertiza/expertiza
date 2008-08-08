class MenuUpdateParticipantChoices < ActiveRecord::Migration
  def self.up
     permission1 = Permission.find_by_name('administer assignments')
     site_controller = SiteController.find_or_create_by_name('participant_choices')
     site_controller.permission_id = permission1.id
     site_controller.builtin = 0
     site_controller.save
     Role.rebuild_cache       
  end

  def self.down
    site_controller = SiteController.find_by_name('participant_choices')
    if site_controller != nil
      actions = ControllerAction.find(:all, :conditions => ['site_controller_id = ?',site_controller.id])
      actions.each {|action| 
        menuItems = MenuItem.find(:all, :conditions => ['controller_action_id = ?',action.id])
        menuItems.each{ |item| item.destroy}
        action.destroy
      }
      site_controller.destroy
    end
    Role.rebuild_cache    
  end
end
