
require File.dirname(__FILE__) + '/../test_helper'
require 'question_types_controller'

class QuestionTypesControllerTest < ActionController::TestCase

  test "index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question_types)
  end

  test "new" do
    get :new
    assert_response :success
  end

  test "create question_type" do
    assert_difference('QuestionType.count') do
      post :create, :question_type => { }
    end

    assert_redirected_to question_type_path(assigns(:question_type))
  end

  test "show question_type" do
    get :show, :id => question_types(:one).to_param
    assert_response :success
  end

  test "edit" do
    get :edit, :id => question_types(:one).to_param
    assert_response :success
  end

  test "update question_type" do
    put :update, :id => question_types(:one).to_param, :question_type => { }
    assert_redirected_to question_type_path(assigns(:question_type))
  end

  test "destroy question_type" do
    assert_difference('QuestionType.count', -1) do
      delete :destroy, :id => question_types(:one).to_param
    end

    assert_redirected_to question_types_path
  end
end
