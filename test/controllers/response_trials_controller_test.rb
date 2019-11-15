require 'test_helper'

class ResponseTrialsControllerTest < ActionController::TestCase
  setup do
    @response_trial = response_trials(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:response_trials)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create response_trial" do
    assert_difference('ResponseTrial.count') do
      post :create, response_trial: {  }
    end

    assert_redirected_to response_trial_path(assigns(:response_trial))
  end

  test "should show response_trial" do
    get :show, id: @response_trial
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @response_trial
    assert_response :success
  end

  test "should update response_trial" do
    patch :update, id: @response_trial, response_trial: {  }
    assert_redirected_to response_trial_path(assigns(:response_trial))
  end

  test "should destroy response_trial" do
    assert_difference('ResponseTrial.count', -1) do
      delete :destroy, id: @response_trial
    end

    assert_redirected_to response_trials_path
  end
end
