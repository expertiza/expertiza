class PermissionForQuizQuestionnaire < ActiveRecord::Migration
  def self.up
    controller_id = SiteController.find_by_name('questionnaire').id
    do_assignments_id = Permission.find_by_name("do assignments").id
    actions = ['new_quiz', 'create_quiz_questionnaire', 'update_quiz', 'edit_quiz', 'view_quiz']
    for action in actions do
    unless ControllerAction.find_by_site_controller_id_and_name(controller_id, action)
      ControllerAction.create :site_controller_id => controller_id, :name => action, :permission_id => do_assignments_id, :url_to_use => ''
    end
    end
    Role.rebuild_cache
  end

  def self.down
    controller_id = SiteController.find_by_name('questionnaire').id
    actions = ['new_quiz', 'create_quiz_questionnaire', 'update_quiz', 'edit_quiz', 'view_quiz']
    for action in actions do
    ControllerAction.find_all_by_site_controller_id_and_name(controller_id, action).each &:destroy
    end
    Role.rebuild_cache
  end
end
