class PermissionForAdvertiseForPartners < ActiveRecord::Migration
  def self.up
    do_assignments_id = Permission.find_by_name("do assignments").id
    SiteController.create :name => 'advertise_for_partners', :permission_id => do_assignments_id
    SiteController.create :name => 'join_team_requests', :permission_id => do_assignments_id
    controller_id = SiteController.find_by_name('sign_up_sheet').id
    action = 'team_details'
    unless ControllerAction.where(site_controller_id: controller_id, name:  action).first
      ControllerAction.create :site_controller_id => controller_id, :name => action, :permission_id => do_assignments_id, :url_to_use => ''
    end
    Role.rebuild_cache
  end

  def self.down
    SiteController.find_by_name('advertise_for_partners').destroy
    SiteController.find_by_name('join_team_requests').destroy
    controller_id = SiteController.find_by_name('sign_up_sheet').id
    action = 'team_details'
    ControllerAction.where(site_controller_id: controller_id, name: action).find_each(&:destroy)
    Role.rebuild_cache
  end
end
