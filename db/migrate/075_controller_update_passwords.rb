class ControllerUpdatePasswords < ActiveRecord::Migration
  def self.up
    controller = SiteController.find_by_name('auth')
    if controller 
      action = ControllerAction.where(name: 'forgotten', site_controller_id: controller.id).first
      if action
        action.destroy
      end
    end
    
    permission = Permission.find_by_name('public actions - execute') 
    controller = SiteController.find_or_create_by(name: 'password_retrieval')
    controller.permission_id = permission.id
    controller.save
    
    Role.rebuild_cache 
  end

  def self.down
    controller = SiteController.find_by_name('password_retrieval')
    permission_id = controller.permission_id
    controller.destroy
    
    controller = SiteController.find_by_name('auth')
    ControllerAction.create(:name => 'forgotten', :site_controller_id => controller.id, :permission_id => permission_id)
  end
end
