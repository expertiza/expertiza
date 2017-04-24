require 'test_helper'

class ReviewMetricMappingsControllerTest < ActionController::TestCase
  setup do
    @review_metric_mapping = review_metric_mappings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:review_metric_mappings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create review_metric_mapping" do
    assert_difference('ReviewMetricMapping.count') do
      post :create, review_metric_mapping: { metric_link: @review_metric_mapping.metric_link, response_link: @review_metric_mapping.response_link, value: @review_metric_mapping.value }
    end

    assert_redirected_to review_metric_mapping_path(assigns(:review_metric_mapping))
  end

  test "should show review_metric_mapping" do
    get :show, id: @review_metric_mapping
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @review_metric_mapping
    assert_response :success
  end

  test "should update review_metric_mapping" do
    patch :update, id: @review_metric_mapping, review_metric_mapping: { metric_link: @review_metric_mapping.metric_link, response_link: @review_metric_mapping.response_link, value: @review_metric_mapping.value }
    assert_redirected_to review_metric_mapping_path(assigns(:review_metric_mapping))
  end

  test "should destroy review_metric_mapping" do
    assert_difference('ReviewMetricMapping.count', -1) do
      delete :destroy, id: @review_metric_mapping
    end

    assert_redirected_to review_metric_mappings_path
  end
end
