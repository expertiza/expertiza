class MenuUpdateUsers < ActiveRecord::Migration[4.2]
  def self.up
    permission = Permission.find_by_name('administer assignments')
    unless permission.nil?
      site_controller = SiteController.find_by_name('users')
      unless site_controller.nil?
        action = ControllerAction.where(['site_controller_id = ? and name = ?', site_controller.id, 'list']).first
        unless action.nil?
          action.permission_id = permission.id
          action.save
        end
      end
      page = ContentPage.find_by_name('site_admin')
      unless page.nil?
        page.permission_id = permission.id
        page.save
      end
      page = ContentPage.find_by_name('admin')
      unless page.nil?
        page.permission_id = permission.id
        page.save
      end
    end
    Role.rebuild_cache
  end

  def self.down
    site_controller = SiteController.find_by_name('users')
    unless site_controller.nil?
      action = ControllerAction.where(['site_controller_id = ? and name = ?', site_controller.id, 'list']).first
      unless action.nil?
        action.permission_id = nil
        action.save
      end
    end

    Role.rebuild_cache
  end
end
