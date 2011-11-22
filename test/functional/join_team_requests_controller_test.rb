require 'test_helper'

class JoinTeamRequestsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:join_team_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create join_team_request" do
    assert_difference('JoinTeamRequest.count') do
      post :create, :join_team_request => { }
    end

    assert_redirected_to join_team_request_path(assigns(:join_team_request))
  end

  test "should show join_team_request" do
    get :show, :id => join_team_requests(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => join_team_requests(:one).to_param
    assert_response :success
  end

  test "should update join_team_request" do
    put :update, :id => join_team_requests(:one).to_param, :join_team_request => { }
    assert_redirected_to join_team_request_path(assigns(:join_team_request))
  end

  test "should destroy join_team_request" do
    assert_difference('JoinTeamRequest.count', -1) do
      delete :destroy, :id => join_team_requests(:one).to_param
    end

    assert_redirected_to join_team_requests_path
  end
end
