require 'test_helper'

class SubmissionRecordsControllerTest < ActionController::TestCase
  setup do
    @submission_record = submission_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:submission_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create submission_record" do
    assert_difference('SubmissionRecord.count') do
      post :create, submission_record: {  }
    end

    assert_redirected_to submission_record_path(assigns(:submission_record))
  end

  test "should show submission_record" do
    get :show, id: @submission_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @submission_record
    assert_response :success
  end

  test "should update submission_record" do
    patch :update, id: @submission_record, submission_record: {  }
    assert_redirected_to submission_record_path(assigns(:submission_record))
  end

  test "should destroy submission_record" do
    assert_difference('SubmissionRecord.count', -1) do
      delete :destroy, id: @submission_record
    end

    assert_redirected_to submission_records_path
  end
end
