require 'test_helper'

class RevisionPlanTeamMapsControllerTest < ActionController::TestCase
  setup do
    @revision_plan_team_map = revision_plan_team_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:revision_plan_team_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create revision_plan_team_map" do
    assert_difference('RevisionPlanTeamMap.count') do
      post :create, revision_plan_team_map: { revision_plan_team_map_id: @revision_plan_team_map.revision_plan_team_map_id, team_id: @revision_plan_team_map.team_id, used_in_round: @revision_plan_team_map.used_in_round }
    end

    assert_redirected_to revision_plan_team_map_path(assigns(:revision_plan_team_map))
  end

  test "should show revision_plan_team_map" do
    get :show, id: @revision_plan_team_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @revision_plan_team_map
    assert_response :success
  end

  test "should update revision_plan_team_map" do
    patch :update, id: @revision_plan_team_map, revision_plan_team_map: { revision_plan_team_map_id: @revision_plan_team_map.revision_plan_team_map_id, team_id: @revision_plan_team_map.team_id, used_in_round: @revision_plan_team_map.used_in_round }
    assert_redirected_to revision_plan_team_map_path(assigns(:revision_plan_team_map))
  end

  test "should destroy revision_plan_team_map" do
    assert_difference('RevisionPlanTeamMap.count', -1) do
      delete :destroy, id: @revision_plan_team_map
    end

    assert_redirected_to revision_plan_team_maps_path
  end
end
