require 'test_helper'

class SampleSubmissionsControllerTest < ActionController::TestCase
  setup do
    @sample_submission = sample_submissions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sample_submissions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sample_submission" do
    assert_difference('SampleSubmission.count') do
      post :create, sample_submission: {}
    end

    assert_redirected_to sample_submission_path(assigns(:sample_submission))
  end

  test "should show sample_submission" do
    get :show, id: @sample_submission
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sample_submission
    assert_response :success
  end

  test "should update sample_submission" do
    patch :update, id: @sample_submission, sample_submission: {}
    assert_redirected_to sample_submission_path(assigns(:sample_submission))
  end

  test "should destroy sample_submission" do
    assert_difference('SampleSubmission.count', -1) do
      delete :destroy, id: @sample_submission
    end

    assert_redirected_to sample_submissions_path
  end
end
