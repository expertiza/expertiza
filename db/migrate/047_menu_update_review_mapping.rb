class MenuUpdateReviewMapping < ActiveRecord::Migration[4.2]
  def self.up
    permission1 = Permission.find_by_name('administer assignments')
    menuParent = MenuItem.find_by_label('Assignment Creation')
    site_controller = SiteController.find_or_create_by(name: 'review_mapping')
    site_controller.permission_id = permission1.id
    site_controller.builtin = 0
    site_controller.save
    action = ControllerAction.create(name: 'list', site_controller_id: site_controller.id)
    action.save
    mitem = MenuItem.create(name: 'assign_reviewers', label: 'Assign Reviewers', seq: 1, controller_action_id: action.id, parent_id: menuParent.id)
    mitem.save
    Role.rebuild_cache
  end

  def self.down
    site_controller = SiteController.find_by_name('review_mapping')
    unless site_controller.nil?
      actions = ControllerAction.find(:all, conditions: ['site_controller_id = ?', site_controller.id])
      actions.each do |action|
        menuItems = MenuItem.find(:all, conditions: ['controller_action_id = ?', action.id])
        menuItems.each(&:destroy)
        action.destroy
      end
      site_controller.destroy
    end
    Role.rebuild_cache
  end
end
