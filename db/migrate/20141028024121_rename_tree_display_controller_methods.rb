class RenameTreeDisplayControllerMethods < ActiveRecord::Migration
  def self.up
    permission1 = Permission.find_by_name('administer assignments');

    site_controller = SiteController.find_or_create_by(name: 'tree_display')
    site_controller.permission_id = permission1.id
    site_controller.builtin = 0
    site_controller.save

    action = ControllerAction.where(name: 'list', site_controller_id: site_controller.id).first
    action.update(name: 'index')

    # Get rid of old controller actions associated with tree_display if they exist
    # and update associations
    ControllerAction.where(site_controller_id: site_controller.id).find_each do |controller_action|
      if controller_action.id != action.id
        MenuItem.where(controller_action_id: controller_action.id).find_each do |menu_item|
          menu_item.update(controller_action_id: action.id)
        end
        controller_action.destroy
      end
    end

    # Clear cache and rebuild
    Role.all.find_each do |role|
      role.update(cache: nil)
    end
    Role.rebuild_cache
  end

  def self.down
  end
end










