class UpdateControllersTeammateReview < ActiveRecord::Migration
  def self.up
    perm = Permission.find_by_name("do assignments")
    controller = SiteController.find_or_create_by_name("teammate_review")
    controller.permission_id = perm.id
    controller.save  
    
    ControllerAction.create(:site_controller_id => controller.id, :name => 'new')
    
    teammate_review_action = ControllerAction.find_or_create_by_name('goto_teammate_reviews')
    teammate_review_action.site_controller_id = controller.id
    teammate_review_action.save
    
    controller = SiteController.find_by_name("tree_display")         
    action = ControllerAction.create(:site_controller_id => controller.id, :name => 'goto_teammate_reviews')
    
    item = MenuItem.find_by_name('manage/questionnaires')    
    #maxseq = MenuItem.find_all_by_parent_id(item.id).length
    maxseq = MenuItem.where(parent_id: item.id).length
    MenuItem.create(:name => 'manage/questionnaires/teammate reviews', :label => 'Teammate Review', :parent_id => item.id, :seq => maxseq+1, :controller_action_id => action.id)
        
    Role.rebuild_cache 
  end

  def self.down
  end
end
