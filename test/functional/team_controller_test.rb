require 'test_helper'

class TeamControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :nodes, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  setup do

  end

  test "create teams should redirect to list" do
    get :list, {'id' => teams(:team2).id, 'type' => 'Course'}, session_for(users(:superadmin))
    assert_response :success
    assert_not_nil assigns(:root_node)
    assert_not_nil assigns(:child_nodes)
  end
end
