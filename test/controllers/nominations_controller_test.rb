require 'test_helper'

class NominationsControllerTest < ActionController::TestCase
  setup do
    @nomination = nominations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nominations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nomination" do
    assert_difference('Nomination.count') do
      post :create, nomination: { assignment_badge_id: @nomination.assignment_badge_id, nominator_id: @nomination.nominator_id, recipient_id: @nomination.recipient_id }
    end

    assert_redirected_to nomination_path(assigns(:nomination))
  end

  test "should show nomination" do
    get :show, id: @nomination
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nomination
    assert_response :success
  end

  test "should update nomination" do
    patch :update, id: @nomination, nomination: { assignment_badge_id: @nomination.assignment_badge_id, nominator_id: @nomination.nominator_id, recipient_id: @nomination.recipient_id }
    assert_redirected_to nomination_path(assigns(:nomination))
  end

  test "should destroy nomination" do
    assert_difference('Nomination.count', -1) do
      delete :destroy, id: @nomination
    end

    assert_redirected_to nominations_path
  end
end
