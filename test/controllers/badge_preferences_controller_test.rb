require 'test_helper'

class BadgePreferencesControllerTest < ActionController::TestCase
  setup do
    @badge_preference = badge_preferences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:badge_preferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create badge_preference" do
    assert_difference('BadgePreference.count') do
      post :create, badge_preference: { instructor_id: @badge_preference.instructor_id, preference: @badge_preference.preference }
    end

    assert_redirected_to badge_preference_path(assigns(:badge_preference))
  end

  test "should show badge_preference" do
    get :show, id: @badge_preference
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @badge_preference
    assert_response :success
  end

  test "should update badge_preference" do
    patch :update, id: @badge_preference, badge_preference: { instructor_id: @badge_preference.instructor_id, preference: @badge_preference.preference }
    assert_redirected_to badge_preference_path(assigns(:badge_preference))
  end

  test "should destroy badge_preference" do
    assert_difference('BadgePreference.count', -1) do
      delete :destroy, id: @badge_preference
    end

    assert_redirected_to badge_preferences_path
  end
end
