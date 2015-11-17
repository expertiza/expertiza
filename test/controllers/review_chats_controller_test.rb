require 'test_helper'

class ReviewChatsControllerTest < ActionController::TestCase
  setup do
    @review_chat = review_chats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:review_chats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create review_chat" do
    assert_difference('ReviewChat.count') do
      post :create, review_chat: { assignment_id: @review_chat.assignment_id, content: @review_chat.content, reviewer_id: @review_chat.reviewer_id, team_id: @review_chat.team_id, type_flag: @review_chat.type_flag }
    end

    assert_redirected_to review_chat_path(assigns(:review_chat))
  end

  test "should show review_chat" do
    get :show, id: @review_chat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @review_chat
    assert_response :success
  end

  test "should update review_chat" do
    patch :update, id: @review_chat, review_chat: { assignment_id: @review_chat.assignment_id, content: @review_chat.content, reviewer_id: @review_chat.reviewer_id, team_id: @review_chat.team_id, type_flag: @review_chat.type_flag }
    assert_redirected_to review_chat_path(assigns(:review_chat))
  end

  test "should destroy review_chat" do
    assert_difference('ReviewChat.count', -1) do
      delete :destroy, id: @review_chat
    end

    assert_redirected_to review_chats_path
  end
end
