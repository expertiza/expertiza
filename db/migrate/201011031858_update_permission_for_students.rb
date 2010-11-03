class UpdatePermissionForStudents < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('do assignments')

    controller = SiteController.find_or_create_by_name('questionnaire')
    controller.permission_id = permission.id
    controller.save!

    ['create_questionnaire', 'edit_questionnaire', 'save_questionnaire', 'copy_questionnaire', 'list', 'new'].each do |name|
      action = ControllerAction.find_or_create_by_name_and_site_controller_id(name, controller.id)
      action.permission_id = permission.id
      action.save!
    end
        
    Role.rebuild_cache
  end

  def self.down
  end
end
