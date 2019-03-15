require 'test_helper'

class AccountRequestsControllerTest < ActionController::TestCase
  setup do
    @account_request = account_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:account_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create account_request" do
    assert_difference('AccountRequest.count') do
      post :create, account_request: { email: @account_request.email, fullname: @account_request.fullname, institution_id: @account_request.institution_id, name: @account_request.name, role_id: @account_request.role_id, self_introduction: @account_request.self_introduction, status: @account_request.status }
    end

    assert_redirected_to account_request_path(assigns(:account_request))
  end

  test "should show account_request" do
    get :show, id: @account_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @account_request
    assert_response :success
  end

  test "should update account_request" do
    patch :update, id: @account_request, account_request: { email: @account_request.email, fullname: @account_request.fullname, institution_id: @account_request.institution_id, name: @account_request.name, role_id: @account_request.role_id, self_introduction: @account_request.self_introduction, status: @account_request.status }
    assert_redirected_to account_request_path(assigns(:account_request))
  end

  test "should destroy account_request" do
    assert_difference('AccountRequest.count', -1) do
      delete :destroy, id: @account_request
    end

    assert_redirected_to account_requests_path
  end
end
