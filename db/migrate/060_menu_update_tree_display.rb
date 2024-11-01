class MenuUpdateTreeDisplay < ActiveRecord::Migration[4.2]
  def self.up
    permission1 = Permission.find_by_name('administer assignments')
    menu = MenuItem.find_by_label('Assignment Creation')
    menu.delete if menu
    menu = MenuItem.find_by_label('Participants')
    menu.delete if menu
    menu = MenuItem.find_by_label('Questionnaires')
    menu.delete if menu
    menu = MenuItem.find_by_label('Courses')
    menu.delete if menu

    site_controller = SiteController.find_or_create_by(name: 'survey_deployment')
    site_controller.permission_id = permission1.id
    site_controller.save
    action = ControllerAction.where(['site_controller_id = ? and name = ?', site_controller.id, 'list']).first
    if action.nil?
      action = ControllerAction.create(name: 'list', site_controller_id: site_controller.id)
    end
    menuParent = MenuItem.create(parent_id: nil, name: 'Survey Deployments', label: 'Survey Deployments', seq: 3, controller_action_id: action.id)

    site_controller = SiteController.find_or_create_by(name: 'statistics')
    site_controller.permission_id = permission1.id
    site_controller.save
    action = ControllerAction.where(['site_controller_id = ? and name = ?', site_controller.id, 'list_surveys']).first
    if action.nil?
      action = ControllerAction.create(name: 'list_surveys', site_controller_id: site_controller.id)
    end
    menuParent = MenuItem.create(parent_id: menuParent.id, name: 'Statistical Test', label: 'Statistical Test', seq: 3, controller_action_id: action.id)

    site_controller = SiteController.find_or_create_by(name: 'tree_display')
    site_controller.permission_id = permission1.id
    site_controller.builtin = 0
    site_controller.save
    action = ControllerAction.create(name: 'list', site_controller_id: site_controller.id)
    action.save

    menu = MenuItem.find_by_label('Administration')
    menu.controller_action_id = action.id
    menu.content_page_id = nil
    menu.save

    Role.rebuild_cache
  end

  def self.down
    site_controller = SiteController.find_by_name('tree_display')
    unless site_controller.nil?
      actions = ControllerAction.where(['site_controller_id = ?', site_controller.id])
      actions.each do |action|
        menuItems = MenuItem.where(['controller_action_id = ?', action.id])
        menuItems.each(&:destroy)
        action.destroy
      end
      site_controller.destroy
    end
    Role.rebuild_cache

    site_controller = SiteController.find_by_name('assignment')
    action = ControllerAction.where(['site_controller_id = ? and name = "list"', site_controller.id]).first
    menuParent = MenuItem.create(name: 'assignments', label: 'Assignment Creation', controller_action_id: action.id, seq: 4)
    menuParent.save
  end
end
