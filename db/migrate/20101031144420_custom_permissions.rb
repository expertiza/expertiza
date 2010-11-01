class CustomPermissions < ActiveRecord::Migration
  def self.up
    #adding permissions to permissions table so that students can access methods created by our project
  #adding all required permissions for this enhancements, cannot avoid code repetition
  #migrate errors out if you have a function call.
  
  controller = SiteController.find_by_name('suggestion')
    permission = Permission.find_by_name('Public pages - view')
    action = ControllerAction.find_or_create_by_name('view_suggestion')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

   controller = SiteController.find_by_name('suggestion')
    permission = Permission.find_by_name('Public pages - view')
    action = ControllerAction.find_or_create_by_name('show')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save
  
   controller = SiteController.find_by_name('suggestion')
    permission = Permission.find_by_name('Public pages - view')
    action = ControllerAction.find_or_create_by_name('edit')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save
 
   controller = SiteController.find_by_name('suggestion')
    permission = Permission.find_by_name('Public pages - view')
    action = ControllerAction.find_or_create_by_name('update')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

   controller = SiteController.find_by_name('suggestion')
    permission = Permission.find_by_name('Public pages - view')
    action = ControllerAction.find_or_create_by_name('back_send')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save
  
   controller = SiteController.find_by_name('suggestion')
    permission = Permission.find_by_name('do assignments')
    action = ControllerAction.find_or_create_by_name('list')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save
  
  
   controller = SiteController.find_by_name('suggestion')
    permission = Permission.find_by_name('Public pages - view')
    action = ControllerAction.find_or_create_by_name('activity')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save
  
  
   controller = SiteController.find_by_name('sign_up_sheet')
    permission = Permission.find_by_name('do assignments')
    action = ControllerAction.new
    action.name ='show'
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    Role.rebuild_cache
  end

  
  def self.down
  end
end
