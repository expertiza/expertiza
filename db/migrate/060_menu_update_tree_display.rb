class MenuUpdateTreeDisplay < ActiveRecord::Migration
  def self.up
     permission1 = Permission.find_by_name('administer assignments');
     menu = MenuItem.find_by_label('Assignment Creation')
     if menu
       menu.delete
     end
     menu = MenuItem.find_by_label('Participants')
     if menu
       menu.delete
     end
     menu = MenuItem.find_by_label('Questionnaires')
     if menu 
       menu.delete
     end
     menu = MenuItem.find_by_label('Courses')
     if menu
       menu.delete
     end

     site_controller = SiteController.find_or_create_by_name('survey_deployment')
     site_controller.permission_id = permission1.id
     site_controller.save
     #action = ControllerAction.find(:first, :conditions => ['site_controller_id = ? and name = ?',site_controller.id,'list'])  
     action = ControllerAction.where(site_controller_id: site_controller.id, name: 'list').first
     if action == nil
       action = ControllerAction.create(:name => 'list', :site_controller_id => site_controller.id)
     end
     menuParent = MenuItem.create(:parent_id => nil, :name => 'Survey Deployments', :label => 'Survey Deployments', :seq => 3, :controller_action_id =>action.id )
     
     site_controller = SiteController.find_or_create_by_name('statistics')
     site_controller.permission_id = permission1.id
     site_controller.save
     #action = ControllerAction.find(:first, :conditions => ['site_controller_id = ? and name = ?',site_controller.id,'list_surveys'])
     action = ControllerAction.where(site_controller_id: site_controller.id, name: 'list_surveys').first 
     if action == nil
       action = ControllerAction.create(:name => 'list_surveys', :site_controller_id => site_controller.id)
     end
     menuParent = MenuItem.create(:parent_id => menuParent.id, :name => 'Statistical Test', :label => 'Statistical Test', :seq => 3, :controller_action_id =>action.id )
     
     site_controller = SiteController.find_or_create_by_name('tree_display')
     site_controller.permission_id = permission1.id
     site_controller.builtin = 0
     site_controller.save
     action = ControllerAction.create(:name => 'list',:site_controller_id => site_controller.id)
     action.save
     
     menu = MenuItem.find_by_label('Administration')
     menu.controller_action_id = action.id
     menu.content_page_id = nil
     menu.save
     
     Role.rebuild_cache      
  end

  def self.down        
    site_controller = SiteController.find_by_name('tree_display')
    if site_controller != nil
      actions = ControllerAction.find(:all, :conditions => ['site_controller_id = ?',site_controller.id])
      actions.each {|action| 
        menuItems = MenuItem.find(:all, :conditions => ['controller_action_id = ?',action.id])
        menuItems.each{ |item| item.destroy}
        action.destroy
      }
      site_controller.destroy
    end
    Role.rebuild_cache
    
    site_controller = SiteController.find_by_name('assignment')
    action = ControllerAction.find(:first, :conditions => ['site_controller_id = ? and name = "list"',site_controller.id])    
    menuParent = MenuItem.create(:name=> 'assignments', :label => 'Assignment Creation', :controller_action_id => action.id, :seq => 4)
    menuParent.save
  end
end
