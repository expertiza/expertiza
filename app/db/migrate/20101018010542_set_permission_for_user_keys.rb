class SetPermissionForUserKeys < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('do assignments')
    controller = SiteController.find_or_create_by_name('users')
    controller.permission_id = permission.id
    controller.save

    action = ControllerAction.find_or_create_by_name('keys')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    Role.rebuild_cache
  end

  def self.down
  end
end
