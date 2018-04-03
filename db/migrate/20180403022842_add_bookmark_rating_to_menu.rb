class AddBookmarkRatingToMenu < ActiveRecord::Migration
  def change
   site_controller = SiteController.find_by_name('tree_display')
    
    bookmarkrating_rubrics_action = ControllerAction.find_or_create_by(name: 'goto_bookmarkrating_rubrics')
    bookmarkrating_rubrics_action.site_controller_id = site_controller.id
    bookmarkrating_rubrics_action.save
    item = MenuItem.find_by_name('manage/questionnaires')
    MenuItem.create(:name => 'manage/questionnaires/bookmark rating rubrics', :label => 'Bookmark rating', :parent_id => item.id, :seq => 8, :controller_action_id => bookmarkrating_rubrics_action.id)
  end
end
