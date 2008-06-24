class MenuUpdateReviewMapping < ActiveRecord::Migration
  def self.up
     permission1 = Permission.find_by_name('administer assignments');
     menuParent = MenuItem.find_by_label('Assignment Creation')
     site_controller = SiteController.create(:name => 'review_mapping', :permission_id => permission1.id, :builtin => 0)
     action = ControllerAction.create(:name => 'list',:site_controller_id => site_controller.id)
     MenuItem.create(:name =>'assign_reviewers', :label => 'Assign Reviewers',:seq => 1, :controller_action_id => action.id, :parent_id => menuParent.id )     
     Role.rebuild_cache    
  end

  def self.down
     menu = MenuItem.find_by_label('Assign Reviewers')
     action = ControllerAction.find(menu.controller_action_id)
     site_controller = SiteController.find(action.site_controller_id)
     site_controller.destroy
     action.destroy
     menu.destroy
     
     Role.rebuild_cache
  end
end
