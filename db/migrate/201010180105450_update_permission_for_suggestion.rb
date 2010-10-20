class UpdatePermissionForSuggestion < ActiveRecord::Migration
  def self.up
    controller = SiteController.find_or_create_by_name('suggestion')

    permission = Permission.find_by_name('do assignments')
    action = ControllerAction.find_or_create_by_name('edit_suggestion')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.save

    action = ControllerAction.find_or_create_by_name('view_comments')
    action.site_controller_id = controller.id
    action.permission_id = permission.id
    action.url_to_use = 'view_comments'
    action.save

    Role.rebuild_cache
  end

  def self.down
  end
end
