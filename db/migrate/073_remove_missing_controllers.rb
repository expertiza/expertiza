class RemoveMissingControllers < ActiveRecord::Migration[4.2]
  def self.up
    controller = SiteController.find_by_name('courses_users')
    if controller
      ControllerAction.where(site_controller_id: controller.id).find_each do |action|
        MenuItem.where(controller_action_id: action.id).find_each(&:destroy)
        action.destroy
      end
      controller.destroy
  end

    controller = SiteController.find_by_name('publishing')
    if controller
      ControllerAction.where(site_controller_id: controller.id).find_each do |action|
        MenuItem.find_all_by(controller_action_id: action.id).each(&:destroy)
        action.destroy
      end
      controller.destroy
  end

    controller = SiteController.find_by_name('submission')
    if controller
      ControllerAction.where(site_controller_id: controller.id).find_each do |action|
        MenuItem.where(controller_action_id: action.id).find_each(&:destroy)
        action.destroy
      end
      controller.destroy
    end
  end

  def self.down; end
end
