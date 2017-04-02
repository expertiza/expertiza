require 'rails_helper'

describe NotificationsController do
  it "#run_get_notification" do
    get :notification_url
    assert_response :success
  end
  it "#run_create_notification" do
    assert_difference('Notification.count') do
      post notification_url, params: {notification: @notification}
    end

    assert_redirected_to notification_path(Article.last)
    assert_equal 'Notification was successfully created.', flash[:notice]
  end

  it "#run_update_notification" do
    notification = notification(:one)
    patch notification_url(notification), params: {article: {title: "updated"}}
    assert_redirected_to notification_path(notification)
    notification.reload
    assert_equal 'Notification was successfully created.', flash[:notice]
  end

  it "#run_destroy_notification" do
    assert_difference('notification.count', -1) do
      delete notification_url(@notification)
    end

    assert_redirected_to notification_path
  end
end
