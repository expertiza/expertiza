require 'test_helper'

class SubmissionrecordsControllerTest < ActionController::TestCase
  setup do
    @submissionrecord = submissionrecords(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:submissionrecords)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create submissionrecord" do
    assert_difference('Submissionrecord.count') do
      post :create, submissionrecord: {  }
    end

    assert_redirected_to submissionrecord_path(assigns(:submissionrecord))
  end

  test "should show submissionrecord" do
    get :show, id: @submissionrecord
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @submissionrecord
    assert_response :success
  end

  test "should update submissionrecord" do
    patch :update, id: @submissionrecord, submissionrecord: {  }
    assert_redirected_to submissionrecord_path(assigns(:submissionrecord))
  end

  test "should destroy submissionrecord" do
    assert_difference('Submissionrecord.count', -1) do
      delete :destroy, id: @submissionrecord
    end

    assert_redirected_to submissionrecords_path
  end
end
