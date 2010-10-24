require 'test_helper'

class CodeReviewFilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:code_review_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create code_review_file" do
    assert_difference('CodeReviewFile.count') do
      post :create, :code_review_file => { }
    end

    assert_redirected_to code_review_file_path(assigns(:code_review_file))
  end

  test "should show code_review_file" do
    get :show, :id => code_review_files(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => code_review_files(:one).id
    assert_response :success
  end

  test "should update code_review_file" do
    put :update, :id => code_review_files(:one).id, :code_review_file => { }
    assert_redirected_to code_review_file_path(assigns(:code_review_file))
  end

  test "should destroy code_review_file" do
    assert_difference('CodeReviewFile.count', -1) do
      delete :destroy, :id => code_review_files(:one).id
    end

    assert_redirected_to code_review_files_path
  end
end
