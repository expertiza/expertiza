class PermissionForMetareviewAssignment < ActiveRecord::Migration
  def self.up
    controller_id = SiteController.find_by_name('review_mapping').id
    do_assignments_id = Permission.find_by_name("do assignments").id
    action = 'assign_metareviewer_dynamically'
    unless ControllerAction.where(site_controller_id: controller_id, name:  action).first
      ControllerAction.create :site_controller_id => controller_id, :name => action, :permission_id => do_assignments_id, :url_to_use => ''
    end
    Role.rebuild_cache
  end

  def self.down
    controller_id = SiteController.find_by_name('review_mapping').id
    action = 'assign_metareviewer_dynamically'
    ControllerAction.where(site_controller_id: controller_id, name: action).find_each(&:destroy)
    Role.rebuild_cache
  end
end
