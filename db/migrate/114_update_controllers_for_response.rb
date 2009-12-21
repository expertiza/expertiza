class UpdateControllersForResponse < ActiveRecord::Migration
  def self.up
    perm = Permission.find_by_name("do assignments")
    
    controller = SiteController.find_or_create_by_name("response")
    controller.permission_id = perm.id
    controller.save    
    
    controller = SiteController.find_by_name("review")
    ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
    controller.destroy
    
    controller = SiteController.find_by_name("reviewing")
    ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
    controller.destroy
    
    controller = SiteController.find_by_name("review_feedback")
    ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
    controller.destroy
    
    controller = SiteController.find_by_name("review_of_review")
    ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
    controller.destroy    
    
    controller = SiteController.find_by_name("teammate_review")
    ControllerAction.find_all_by_site_controller_id(controller.id).each{|action| action.destroy}
    controller.destroy      
    
    Role.rebuild_cache
  end

  def self.down
  end
end
