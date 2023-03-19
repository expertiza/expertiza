class ControllerUpdateCoursesUsers < ActiveRecord::Migration[4.2]
  def self.up
    permission1 = Permission.find_or_create_by(name: 'administer courses')
    site_controller = SiteController.find_or_create_by(name: 'courses_users')
    site_controller.permission_id = permission1.id
    site_controller.save
    Role.rebuild_cache
  end

  def self.down
    site_controller = SiteController.find_by_name('courses_users')
    unless site_controller.nil?
      actions = ControllerAction.where(['site_controller_id = ?', site_controller.id])
      actions.each do |action|
        menuItems = MenuItem.where(['controller_action_id = ?', action.id])
        menuItems.each(&:destroy)
        action.destroy
      end
      site_controller.destroy
    end
    Role.rebuild_cache
  end
end
