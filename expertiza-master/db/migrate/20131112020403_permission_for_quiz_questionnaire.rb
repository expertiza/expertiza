class PermissionForQuizQuestionnaire < ActiveRecord::Migration
  def self.up
    controller_id = SiteController.find_by_name('questionnaire').id
    do_assignments_id = Permission.find_by_name("do assignments").id
    actions = ['new_quiz', 'create_quiz_questionnaire', 'update_quiz', 'edit_quiz', 'view_quiz']
    for action in actions do
      unless ControllerAction.where(site_controller_id: controller_id, name:  action).first
        ControllerAction.create :site_controller_id => controller_id, :name => action, :permission_id => do_assignments_id, :url_to_use => ''
      end
    end
    Role.rebuild_cache
  end

  def self.down
    controller_id = SiteController.find_by_name('questionnaire').id
    actions = ['new_quiz', 'create_quiz_questionnaire', 'update_quiz', 'edit_quiz', 'view_quiz']
    for action in actions do
      ControllerAction.where(site_controller_id: controller_id, name: action).find_each(&:destroy)
    end
    Role.rebuild_cache
  end
end
