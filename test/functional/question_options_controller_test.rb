require 'test_helper'

class QuestionOptionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question_options)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create question_option" do
    assert_difference('QuestionOption.count') do
      post :create, :question_option => { }
    end

    assert_redirected_to question_option_path(assigns(:question_option))
  end

  test "should show question_option" do
    get :show, :id => question_options(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => question_options(:one).to_param
    assert_response :success
  end

  test "should update question_option" do
    put :update, :id => question_options(:one).to_param, :question_option => { }
    assert_redirected_to question_option_path(assigns(:question_option))
  end

  test "should destroy question_option" do
    assert_difference('QuestionOption.count', -1) do
      delete :destroy, :id => question_options(:one).to_param
    end

    assert_redirected_to question_options_path
  end
end
