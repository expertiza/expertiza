class SetPermissionsForSignUpSheet < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('administer assignments')
    controller = SiteController.find_or_create_by(name: 'sign_up_sheet')
    controller.permission_id = permission.id
    controller.save

    permission = Permission.find_by_name('do assignments')
    action = ControllerAction.find_or_create_by(name: 'signup_topics')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    action = ControllerAction.find_or_create_by(name: 'signup')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    action = ControllerAction.find_or_create_by(name: 'delete_signup')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save
    Role.rebuild_cache
  end

  def self.down
  end
end
