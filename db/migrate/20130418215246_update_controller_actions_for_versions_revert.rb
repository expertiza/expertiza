class UpdateControllerActionsForVersionsRevert < ActiveRecord::Migration
  def self.up
    @permission = Permission.find_by_name('public actions - execute')
    @controller = SiteController.find_by_name('versions')
    @action = ControllerAction.find_or_create_by(name: 'revert')
    @action.site_controller_id = @controller.id
    @action.permission_id = @permission.id
    @action.save

    Role.rebuild_cache
  end

  def self.down
  end
end
