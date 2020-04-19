require 'test_helper'

class ReviewBidsControllerTest < ActionController::TestCase
  test "should get review_bid" do
    get :review_bid
    assert_response :success
  end

end
