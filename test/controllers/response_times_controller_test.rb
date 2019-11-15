require 'test_helper'

class ResponseTimesControllerTest < ActionController::TestCase
  setup do
    @response_time = response_times(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:response_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create response_time" do
    assert_difference('ResponseTime.count') do
      post :create, response_time: {  }
    end

    assert_redirected_to response_time_path(assigns(:response_time))
  end

  test "should show response_time" do
    get :show, id: @response_time
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @response_time
    assert_response :success
  end

  test "should update response_time" do
    patch :update, id: @response_time, response_time: {  }
    assert_redirected_to response_time_path(assigns(:response_time))
  end

  test "should destroy response_time" do
    assert_difference('ResponseTime.count', -1) do
      delete :destroy, id: @response_time
    end

    assert_redirected_to response_times_path
  end
end
