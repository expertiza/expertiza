require 'test_helper'

class CodeReviewCommentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:code_review_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create code_review_comments" do
    assert_difference('CodeReviewComments.count') do
      post :create, :code_review_comments => { }
    end

    assert_redirected_to code_review_comments_path(assigns(:code_review_comments))
  end

  test "should show code_review_comments" do
    get :show, :id => code_review_comments(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => code_review_comments(:one).id
    assert_response :success
  end

  test "should update code_review_comments" do
    put :update, :id => code_review_comments(:one).id, :code_review_comments => { }
    assert_redirected_to code_review_comments_path(assigns(:code_review_comments))
  end

  test "should destroy code_review_comments" do
    assert_difference('CodeReviewComments.count', -1) do
      delete :destroy, :id => code_review_comments(:one).id
    end

    assert_redirected_to code_review_comments_path
  end
end
