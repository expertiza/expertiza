require 'test_helper'

class SubmissionHistoriesControllerTest < ActionController::TestCase
  setup do
    @submission_history = submission_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:submission_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create submission_history" do
    assert_difference('SubmissionHistory.count') do
      post :create, submission_history: {  }
    end

    assert_redirected_to submission_history_path(assigns(:submission_history))
  end

  test "should show submission_history" do
    get :show, id: @submission_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @submission_history
    assert_response :success
  end

  test "should update submission_history" do
    patch :update, id: @submission_history, submission_history: {  }
    assert_redirected_to submission_history_path(assigns(:submission_history))
  end

  test "should destroy submission_history" do
    assert_difference('SubmissionHistory.count', -1) do
      delete :destroy, id: @submission_history
    end

    assert_redirected_to submission_histories_path
  end
end
