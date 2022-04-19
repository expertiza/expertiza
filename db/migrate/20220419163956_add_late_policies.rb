class AddLatePolices < ActiveRecord::Migration[5.1]
  def change
    late_policies_action = ControllerAction.find_or_create_by(name: 'goto_late_policies')
    late_policies_action.site_controller_id = site_controller.id
    late_policies_action.save

    manage_item = MenuItem.find_or_create_by(name: 'manage instructor content')
    item = MenuItem.create(name: 'manage/late policies', label: 'Late Policies', parent_id: manage_item.id, seq: 5, controller_action_id: late_policies_action.id)
    item.save
  end
end
