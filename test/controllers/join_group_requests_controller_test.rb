require 'test_helper'

class JoinGroupRequestsControllerTest < ActionController::TestCase
  setup do
    @join_group_request = join_group_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:join_group_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create join_group_request" do
    assert_difference('JoinGroupRequest.count') do
      post :create, join_group_request: { comments: @join_group_request.comments, group_id: @join_group_request.group_id, participant_id: @join_group_request.participant_id, status: @join_group_request.status }
    end

    assert_redirected_to join_group_request_path(assigns(:join_group_request))
  end

  test "should show join_group_request" do
    get :show, id: @join_group_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @join_group_request
    assert_response :success
  end

  test "should update join_group_request" do
    patch :update, id: @join_group_request, join_group_request: { comments: @join_group_request.comments, group_id: @join_group_request.group_id, participant_id: @join_group_request.participant_id, status: @join_group_request.status }
    assert_redirected_to join_group_request_path(assigns(:join_group_request))
  end

  test "should destroy join_group_request" do
    assert_difference('JoinGroupRequest.count', -1) do
      delete :destroy, id: @join_group_request
    end

    assert_redirected_to join_group_requests_path
  end
end
