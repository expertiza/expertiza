require 'test_helper'

class GradingHistoriesControllerTest < ActionController::TestCase
  setup do
    @grading_history = grading_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:grading_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create grading_history" do
    assert_difference('GradingHistory.count') do
      post :create, grading_history: {  }
    end

    assert_redirected_to grading_history_path(assigns(:grading_history))
  end

  test "should show grading_history" do
    get :show, id: @grading_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @grading_history
    assert_response :success
  end

  test "should update grading_history" do
    patch :update, id: @grading_history, grading_history: {  }
    assert_redirected_to grading_history_path(assigns(:grading_history))
  end

  test "should destroy grading_history" do
    assert_difference('GradingHistory.count', -1) do
      delete :destroy, id: @grading_history
    end

    assert_redirected_to grading_histories_path
  end
end
