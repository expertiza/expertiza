require 'test_helper'

class ReviewBidsControllerTest < ActionController::TestCase
  setup do
    @review_bid = review_bids(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:review_bids)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create review_bid" do
    assert_difference('ReviewBid.count') do
      post :create, review_bid: {  }
    end

    assert_redirected_to review_bid_path(assigns(:review_bid))
  end

  test "should show review_bid" do
    get :show, id: @review_bid
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @review_bid
    assert_response :success
  end

  test "should update review_bid" do
    patch :update, id: @review_bid, review_bid: {  }
    assert_redirected_to review_bid_path(assigns(:review_bid))
  end

  test "should destroy review_bid" do
    assert_difference('ReviewBid.count', -1) do
      delete :destroy, id: @review_bid
    end

    assert_redirected_to review_bids_path
  end
end
