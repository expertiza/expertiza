require 'test_helper'

class GroupInvitationsControllerTest < ActionController::TestCase
  setup do
    @group_invitation = group_invitations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_invitations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_invitation" do
    assert_difference('GroupInvitation.count') do
      post :create, group_invitation: {  }
    end

    assert_redirected_to group_invitation_path(assigns(:group_invitation))
  end

  test "should show group_invitation" do
    get :show, id: @group_invitation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_invitation
    assert_response :success
  end

  test "should update group_invitation" do
    patch :update, id: @group_invitation, group_invitation: {  }
    assert_redirected_to group_invitation_path(assigns(:group_invitation))
  end

  test "should destroy group_invitation" do
    assert_difference('GroupInvitation.count', -1) do
      delete :destroy, id: @group_invitation
    end

    assert_redirected_to group_invitations_path
  end
end
