require 'test_helper'

class TeamControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :nodes, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  setup do
  end

  test "list should accept course_node" do
    get :list, {'id' => nodes(:node23).node_object_id, 'type' => 'Course'}, session_for(users(:superadmin))
    assert_response :success
    assert_not_nil assigns(:root_node)
    assert_not_nil assigns(:child_nodes)
  end

  test "list should accept assignment_node" do
    get :list, {'id' => nodes(:node11).node_object_id, 'type' => 'Assignment'}, session_for(users(:superadmin))
    assert_response :success
    assert_not_nil assigns(:root_node)
    assert_not_nil assigns(:child_nodes)
  end

  test "new should assign parent" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"

    get :new, {'id' => nodes(:node23).node_object_id}, sessionVars
    assert_response :success
    assert_not_nil assigns(:parent)
  end

  test "create should increase number of teams" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"

    assert_difference 'Team.count' do
      post :create, {'id' => nodes(:node23).node_object_id, 'team' => {'name' => "SomeTeamName"}}, sessionVars
    end
  end

  test "create should increase number of team nodes" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"

    assert_difference 'TeamNode.count' do
      post :create, {'id' => nodes(:node23).node_object_id, 'team' => {'name' => "SomeTeamName"}}, sessionVars
    end
  end

  test "create should redirect to list" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"
    nodeId = nodes(:node23).node_object_id

    post :create, {'id' => nodeId, 'team' => {'name' => "SomeTeamName"}}, sessionVars
    assert_redirected_to "team/list/#{nodeId}"
  end
end