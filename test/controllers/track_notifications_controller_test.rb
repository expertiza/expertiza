require 'test_helper'

class TrackNotificationsControllerTest < ActionController::TestCase
  setup do
    @track_notification = track_notifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:track_notifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create track_notification" do
    assert_difference('TrackNotification.count') do
      post :create, track_notification: { notification: @track_notification.notification, user_id: @track_notification.user_id }
    end

    assert_redirected_to track_notification_path(assigns(:track_notification))
  end

  test "should show track_notification" do
    get :show, id: @track_notification
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @track_notification
    assert_response :success
  end

  test "should update track_notification" do
    patch :update, id: @track_notification, track_notification: { notification: @track_notification.notification, user_id: @track_notification.user_id }
    assert_redirected_to track_notification_path(assigns(:track_notification))
  end

  test "should destroy track_notification" do
    assert_difference('TrackNotification.count', -1) do
      delete :destroy, id: @track_notification
    end

    assert_redirected_to track_notifications_path
  end
end
