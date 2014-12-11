class RemoveMissingControllers < ActiveRecord::Migration
  def self.up
     controller = SiteController.find_by_name('courses_users')
     if controller 
       ControllerAction.where(site_controller_id: controller.id).find_each {
          | action | 
          MenuItem.where(controller_action_id: action.id).find_each {
             |item| 
             item.destroy
          }
          action.destroy
       }
       controller.destroy
   end
   
     controller = SiteController.find_by_name('publishing')
     if controller 
       ControllerAction.where(site_controller_id: controller.id).find_each { | action | 
          MenuItem.find_all_by(controller_action_id: action.id).each{
             |item| 
             item.destroy
          }
          action.destroy
       }
       controller.destroy
   end
   
        controller = SiteController.find_by_name('submission')
     if controller 
       ControllerAction.where(site_controller_id: controller.id).find_each{
          | action | 
          MenuItem.where(controller_action_id: action.id).find_each{
             |item| 
             item.destroy
          }
          action.destroy
       }
       controller.destroy
     end
  end

  def self.down
  end
end
