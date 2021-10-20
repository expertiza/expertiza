class PermissionForReviewMapping < ActiveRecord::Migration
  def self.up
    controller_id = SiteController.find_by_name('review_mapping').id
    do_assignments_id = Permission.find_by_name("do assignments").id
    ['show_available_submissions', 'assign_reviewer_dynamically'].each do |action|
      unless ControllerAction.where(site_controller_id: controller_id, name:  action).first
        ControllerAction.create :site_controller_id => controller_id, :name => action, :permission_id => do_assignments_id, :url_to_use => ''
      end
    end
    Role.rebuild_cache
  end

  def self.down
    controller_id = SiteController.find_by_name('review_mapping').id
    ['show_available_submissions', 'assign_reviewer_dynamically'].each do |action|
      ControllerAction.where(site_controller_id: controller_id, name: action).find_each(&:destroy)
    end
    Role.rebuild_cache
  end
end
