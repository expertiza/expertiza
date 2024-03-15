require 'test_helper'

class GradingHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grading_history = grading_histories(:one)
  end

  test "should get index" do
    get grading_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_grading_history_url
    assert_response :success
  end

  test "should create grading_history" do
    assert_difference('GradingHistory.count') do
      post grading_histories_url, params: { grading_history: { comment: @grading_history.comment, grade: @grading_history.grade, grading_type: @grading_history.grading_type } }
    end

    assert_redirected_to grading_history_url(GradingHistory.last)
  end

  test "should show grading_history" do
    get grading_history_url(@grading_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_grading_history_url(@grading_history)
    assert_response :success
  end

  test "should update grading_history" do
    patch grading_history_url(@grading_history), params: { grading_history: { comment: @grading_history.comment, grade: @grading_history.grade, grading_type: @grading_history.grading_type } }
    assert_redirected_to grading_history_url(@grading_history)
  end

  test "should destroy grading_history" do
    assert_difference('GradingHistory.count', -1) do
      delete grading_history_url(@grading_history)
    end

    assert_redirected_to grading_histories_url
  end
end
