class UpdateControllersForResponse < ActiveRecord::Migration
  def self.up
    perm = Permission.find_by_name("do assignments")
    
    controller = SiteController.find_or_create_by_name("response")
    if controller
      controller.permission_id = perm.id
      controller.save
    end
    
    controller = SiteController.find_by_name("review")
    if controller 
      ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
      controller.destroy
    end
    
    controller = SiteController.find_by_name("reviewing")
    if controller
      ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
      controller.destroy
    end
    
    controller = SiteController.find_by_name("review_feedback")
    if controller
      ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
      controller.destroy
    end
    
    controller = SiteController.find_by_name("review_of_review")
    if controller
      ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
      controller.destroy    
    end
    
    controller = SiteController.find_by_name("teammate_review")
    if controller
      ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
      controller.destroy
    end
    
    Role.rebuild_cache
  end

  def self.down
  end
end
