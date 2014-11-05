class RenameTreeDisplayControllerMethods < ActiveRecord::Migration
  def self.up
    permission1 = Permission.find_by_name('administer assignments');

    site_controller = SiteController.find_or_create_by(name: 'tree_display')
    site_controller.permission_id = permission1.id
    site_controller.builtin = 0
    site_controller.save

    index_action = ControllerAction.create(name: 'index', site_controller_id: site_controller.id)
    index_action.save

    # Get rid of old controller actions associated with tree_display if they exist
    # and update associations
    ControllerAction.where(site_controller_id: site_controller.id).find_each do |controller_action|
      if controller_action.id != index_action.id
        MenuItem.where(controller_action_id: controller_action.id).find_each do |menu_item|
          menu_item.update(controller_action_id: index_action.id)
        end
        say "Deleting controller action with id: #{controller_action.id}, index_action.id: #{index_action.id}"
        controller_action.destroy
      end
    end

    Role.rebuild_cache
  end

  def self.down
  end
end