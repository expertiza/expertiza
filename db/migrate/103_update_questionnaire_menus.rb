class UpdateQuestionnaireMenus < ActiveRecord::Migration
  def self.up
    site_controller = SiteController.find_by_name('tree_display')
    
    metareview_rubrics_action = ControllerAction.find_or_create_by(name: 'goto_metareview_rubrics')
    metareview_rubrics_action.site_controller_id = site_controller.id
    metareview_rubrics_action.save
    
    teammatereview_rubrics_action = ControllerAction.find_or_create_by(name: 'goto_teammatereview_rubrics')
    teammatereview_rubrics_action.site_controller_id = site_controller.id
    teammatereview_rubrics_action.save    
    
    item = MenuItem.find_by_name('manage/questionnaires')
    
    MenuItem.create(:name => 'manage/questionnaires/metareview rubrics', :label => 'Metareview rubrics', :parent_id => item.id, :seq => 2, :controller_action_id => metareview_rubrics_action.id)
    MenuItem.create(:name => 'manage/questionnaires/teammate review rubrics', :label => 'Teammate review rubrics', :parent_id => item.id, :seq => 3, :controller_action_id => teammatereview_rubrics_action.id)
    mitem = MenuItem.find_by_label("Teammate Review")
    mitem.destroy
    
    mitem = MenuItem.find_by_name('manage/questionnaires/author feedbacks')
    mitem.seq += 2
    mitem.save
    mitem = MenuItem.find_by_name('manage/questionnaires/global survey')
    mitem.seq += 2
    mitem.save
    mitem = MenuItem.find_by_name('manage/questionnaires/surveys')
    mitem.seq += 2
    mitem.save    
    mitem = MenuItem.find_by_name('manage/questionnaires/course evaluations')
    mitem.seq += 2
    mitem.save        
    
    Role.rebuild_cache
  end

  def self.down
  end
end
