require 'test_helper'

class GroupsUsersControllerTest < ActionController::TestCase
  setup do
    @groups_user = groups_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create groups_user" do
    assert_difference('GroupsUser.count') do
      post :create, groups_user: { group_id: @groups_user.group_id, user_id: @groups_user.user_id }
    end

    assert_redirected_to groups_user_path(assigns(:groups_user))
  end

  test "should show groups_user" do
    get :show, id: @groups_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @groups_user
    assert_response :success
  end

  test "should update groups_user" do
    patch :update, id: @groups_user, groups_user: { group_id: @groups_user.group_id, user_id: @groups_user.user_id }
    assert_redirected_to groups_user_path(assigns(:groups_user))
  end

  test "should destroy groups_user" do
    assert_difference('GroupsUser.count', -1) do
      delete :destroy, id: @groups_user
    end

    assert_redirected_to groups_users_path
  end
end
