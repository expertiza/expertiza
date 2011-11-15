<<<<<<< HEAD
<<<<<<< HEAD
class SetPermissionForSuggestion < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('administer assignments')
    controller = SiteController.find_or_create_by_name('suggestion')
    controller.permission_id = permission.id
    controller.save

    permission = Permission.find_by_name('do assignments')
    action = ControllerAction.find_or_create_by_name('new')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    action = ControllerAction.find_or_create_by_name('create')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    Role.rebuild_cache
  end

  def self.down
  end
end
=======
class SetPermissionForSuggestion < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('administer assignments')
    controller = SiteController.find_or_create_by_name('suggestion')
    controller.permission_id = permission.id
    controller.save

    permission = Permission.find_by_name('do assignments')
    action = ControllerAction.find_or_create_by_name('new')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    action = ControllerAction.find_or_create_by_name('create')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    Role.rebuild_cache
  end

  def self.down
  end
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
class SetPermissionForSuggestion < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('administer assignments')
    controller = SiteController.find_or_create_by_name('suggestion')
    controller.permission_id = permission.id
    controller.save

    permission = Permission.find_by_name('do assignments')
    action = ControllerAction.find_or_create_by_name('new')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    action = ControllerAction.find_or_create_by_name('create')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    Role.rebuild_cache
  end

  def self.down
  end
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
