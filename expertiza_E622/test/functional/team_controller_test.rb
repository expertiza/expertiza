require 'test_helper'

class TeamControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :assignments, :nodes, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  setup do
  end

  test "create_teams_view should assign parent" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"

    get :create_teams_view, {'id' => nodes(:node23).node_object_id}, sessionVars
    assert_response :success
    assert_not_nil assigns(:parent)
  end

  test "delete_all should redirect to list" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"
    nodeId = nodes(:node23).node_object_id

    get :delete_all, {'id' => nodeId}, sessionVars
    assert_redirected_to "/team/list/#{nodeId}"
  end

  test "delete_all should delete team" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"
    nodeId = nodes(:node23).node_object_id

    assert_difference 'Team.count', -1 do
      get :delete_all, {'id' => nodeId}, sessionVars
    end
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
    assert_redirected_to "/team/list/#{nodeId}"
  end

  test "update should redirect to list" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"
    nodeId = nodes(:node23).node_object_id
    teamId = teams(:team2).id

    post :update, {'id' => teamId, 'team' => {'name' => "SomeTeamName"}}, sessionVars
    assert_redirected_to "/team/list/#{nodeId}"
  end

  test "update should raise RecordNotFound" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"
    nodeId = nodes(:node23).node_object_id
    teamId = teams(:team3).id

    assert_raise(ActiveRecord::RecordNotFound) {
      post :update, {'id' => teamId, 'team' => {'name' => "SomeTeamName"}}, sessionVars
    }
  end

  test "delete should decrease number of teams" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"

    assert_difference 'Team.count', -1 do
      get :delete, {'id' => teams(:team2).id}, sessionVars
    end
  end

  test "delete should decrease number of team nodes" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"

    assert_difference 'TeamNode.count', -1 do
      get :delete, {'id' => teams(:team2).id}, sessionVars
    end
  end

  test "delete should redirect to list" do
    sessionVars = session_for(users(:superadmin))
    sessionVars[:team_type] = "Course"
    nodeId = nodes(:node23).node_object_id
    teamId = teams(:team2).id

    get :delete, {'id' => teamId}, sessionVars
    assert_redirected_to "/team/list/#{nodeId}"
  end

  test "inherit should redirect to list" do
    sessionVars = session_for(users(:superadmin))
    assignmentId = assignments(:assignment2).id

    post :inherit, {'id' => assignmentId}, sessionVars
    assert_redirected_to "/team/list/#{assignmentId}"
  end

  test "bequeath should redirect to list" do
    sessionVars = session_for(users(:superadmin))
    teamId = teams(:team4).id
    assignmentId = assignments(:assignment2).id

    post :bequeath, {'id' => teamId}, sessionVars
    assert_redirected_to "/team/list/#{assignmentId}"
  end
end