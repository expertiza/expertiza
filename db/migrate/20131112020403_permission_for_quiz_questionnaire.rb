class PermissionForQuizQuestionnaire < ActiveRecord::Migration[4.2]
  def self.up
    controller_id = SiteController.find_by_name('questionnaire').id
    do_assignments_id = Permission.find_by_name("do assignments").id
    actions = %w[new_quiz create_quiz_questionnaire update_quiz edit_quiz view_quiz]
    actions.each { |action|
      unless ControllerAction.where(site_controller_id: controller_id, name: action).first
        ControllerAction.create :site_controller_id => controller_id, :name => action, :permission_id => do_assignments_id, :url_to_use => ''
      end
    }
    Role.rebuild_cache
  end

  def self.down
    controller_id = SiteController.find_by_name('questionnaire').id
    actions = %w[new_quiz create_quiz_questionnaire update_quiz edit_quiz view_quiz]
    actions.each { |action|
      ControllerAction.where(site_controller_id: controller_id, name: action).find_each(&:destroy)
    }
    Role.rebuild_cache
  end
end
