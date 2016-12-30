require 'test_helper'

class SimicheckComparisonsControllerTest < ActionController::TestCase
  setup do
    @simicheck_comparison = simicheck_comparisons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:simicheck_comparisons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create simicheck_comparison" do
    assert_difference('SimicheckComparison.count') do
      post :create, simicheck_comparison: { comparison_key: @simicheck_comparison.comparison_key, file_type: @simicheck_comparison.file_type }
    end

    assert_redirected_to simicheck_comparison_path(assigns(:simicheck_comparison))
  end

  test "should show simicheck_comparison" do
    get :show, id: @simicheck_comparison
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @simicheck_comparison
    assert_response :success
  end

  test "should update simicheck_comparison" do
    patch :update, id: @simicheck_comparison, simicheck_comparison: { comparison_key: @simicheck_comparison.comparison_key, file_type: @simicheck_comparison.file_type }
    assert_redirected_to simicheck_comparison_path(assigns(:simicheck_comparison))
  end

  test "should destroy simicheck_comparison" do
    assert_difference('SimicheckComparison.count', -1) do
      delete :destroy, id: @simicheck_comparison
    end

    assert_redirected_to simicheck_comparisons_path
  end
end
