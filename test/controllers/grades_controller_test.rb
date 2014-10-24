require 'test_helper'

class GradesControllerTest < ActionController::TestCase
  test "should get show_reviews" do
    get :show_reviews
    assert_response :success
  end

end
