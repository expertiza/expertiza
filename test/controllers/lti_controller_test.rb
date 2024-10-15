require 'test_helper'

class LtiControllerTest < ActionDispatch::IntegrationTest
  test "should get launch" do
    get lti_launch_url
    assert_response :success
  end

end
