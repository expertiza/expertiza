class AddBookmarkQuestionnaireToMenu < ActiveRecord::Migration[4.2]
    def self.up
    site_controller = SiteController.find_by_name('tree_display')

    bookmarkreview_rubrics_action = ControllerAction.find_or_create_by(name: 'goto_bookmark_reviews')
    bookmarkreview_rubrics_action.site_controller_id = site_controller.id
    bookmarkreview_rubrics_action.save

    item = MenuItem.find_by_name('manage/questionnaires')
    maxseq = MenuItem.where(parent_id: item.id).length
    MenuItem.find_or_create_by(name: 'manage/questionnaires/bookmark rating rubrics', label: 'Bookmark Rating rubrics', parent_id: item.id, seq: maxseq + 1, controller_action_id: bookmarkreview_rubrics_action.id)

    Role.rebuild_cache
end

  def self.down
    menu = MenuItem.find_by_label('Bookmark Rating rubrics')
    menu.delete if menu
  end
end
