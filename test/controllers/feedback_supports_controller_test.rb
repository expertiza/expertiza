require 'test_helper'

class FeedbackSupportsControllerTest < ActionController::TestCase
  setup do
    @feedback_support = feedback_supports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feedback_supports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedback_support" do
    assert_difference('FeedbackSupport.count') do
      post :create, feedback_support: {  }
    end

    assert_redirected_to feedback_support_path(assigns(:feedback_support))
  end

  test "should show feedback_support" do
    get :show, id: @feedback_support
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @feedback_support
    assert_response :success
  end

  test "should update feedback_support" do
    patch :update, id: @feedback_support, feedback_support: {  }
    assert_redirected_to feedback_support_path(assigns(:feedback_support))
  end

  test "should destroy feedback_support" do
    assert_difference('FeedbackSupport.count', -1) do
      delete :destroy, id: @feedback_support
    end

    assert_redirected_to feedback_supports_path
  end
end
