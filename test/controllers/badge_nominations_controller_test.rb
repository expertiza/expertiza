require 'test_helper'

class BadgeNominationsControllerTest < ActionController::TestCase
  setup do
    @badge_nomination = badge_nominations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:badge_nominations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create badge_nomination" do
    assert_difference('BadgeNomination.count') do
      post :create, badge_nomination: { assignment_id: @badge_nomination.assignment_id, badge_id: @badge_nomination.badge_id, participant_id: @badge_nomination.participant_id }
    end

    assert_redirected_to badge_nomination_path(assigns(:badge_nomination))
  end

  test "should show badge_nomination" do
    get :show, id: @badge_nomination
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @badge_nomination
    assert_response :success
  end

  test "should update badge_nomination" do
    patch :update, id: @badge_nomination, badge_nomination: { assignment_id: @badge_nomination.assignment_id, badge_id: @badge_nomination.badge_id, participant_id: @badge_nomination.participant_id }
    assert_redirected_to badge_nomination_path(assigns(:badge_nomination))
  end

  test "should destroy badge_nomination" do
    assert_difference('BadgeNomination.count', -1) do
      delete :destroy, id: @badge_nomination
    end

    assert_redirected_to badge_nominations_path
  end
end
