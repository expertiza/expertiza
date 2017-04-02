describe NotificationsController do
  test "should get notifications index" do
    get notification_url
    assert_response :success
  end

  test "should create notification" do
    assert_difference('Notification.count') do
      post notification_url, params: {notification: @notification}
    end

    assert_redirected_to notification_path(Article.last)
    assert_equal 'Notification was successfully created.', flash[:notice]
  end

  test "should update notification" do
    notification = notification(:one)
    patch notification_url(notification), params: {article: {title: "updated"}}
    assert_redirected_to notification_path(notification)
    notification.reload
    assert_equal 'Notification was successfully created.', flash[:notice]
  end

  test "should destroy notification" do
    assert_difference('notification.count', -1) do
      delete notification_url(@notification)
    end

    assert_redirected_to notification_path
  end
end
