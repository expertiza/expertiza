require 'test_helper'

class ReviewMetricsControllerTest < ActionController::TestCase
  setup do
    @review_metric = review_metrics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:review_metrics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create review_metric" do
    assert_difference('ReviewMetric.count') do
      post :create, review_metric: { offensive_term: @review_metric.offensive_term, problem: @review_metric.problem, response_id: @review_metric.response_id, suggestion: @review_metric.suggestion, volume: @review_metric.volume }
    end

    assert_redirected_to review_metric_path(assigns(:review_metric))
  end

  test "should show review_metric" do
    get :show, id: @review_metric
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @review_metric
    assert_response :success
  end

  test "should update review_metric" do
    patch :update, id: @review_metric, review_metric: { offensive_term: @review_metric.offensive_term, problem: @review_metric.problem, response_id: @review_metric.response_id, suggestion: @review_metric.suggestion, volume: @review_metric.volume }
    assert_redirected_to review_metric_path(assigns(:review_metric))
  end

  test "should destroy review_metric" do
    assert_difference('ReviewMetric.count', -1) do
      delete :destroy, id: @review_metric
    end

    assert_redirected_to review_metrics_path
  end
end
