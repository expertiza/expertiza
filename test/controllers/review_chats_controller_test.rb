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

  test "should show review_chat" do
    get :show, id: @review_chat
    assert_response :success
  end
  
    assert_redirected_to review_chats_path
  end
end
