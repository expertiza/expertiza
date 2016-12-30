require 'test_helper'

class LoggerControllerTest < ActionController::TestCase
  test "should get view_logs" do
    get :view_logs
    assert_response :success
  end

end
