class AddLatePoliciestoManage < ActiveRecord::Migration[5.1]
  def change
    content_page = ContentPage.find_by_name('site_admin')
    content_page.permission_id = Permission.find_by_name('administer goldberg').id
    content_page.save
    site_controller = SiteController.find_by_name('tree_display')

    late_policies_action = ControllerAction.find_or_create_by(name: 'goto_late_policies')
    late_policies_action.site_controller_id = site_controller.id
    late_policies_action.save

    manage_item = MenuItem.find_or_create_by(name: 'manage instructor content')
    item = MenuItem.create(name: 'manage/late policies', label: 'Late Policies', parent_id: manage_item.id, seq: 6, controller_action_id: late_policies_action.id)
    item.save
  end
end
