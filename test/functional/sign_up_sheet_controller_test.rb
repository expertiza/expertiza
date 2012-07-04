require 'test_helper'
require 'ruby-debug'
require 'signup_controller'


class SignUpSheetControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  fixtures :sign_up_topics, :assignments, :signed_up_users, :users, :roles, :due_dates
  fixtures :site_controllers, :content_pages, :roles_permissions, :participants
  fixtures :controller_actions, :permissions, :system_settings, :menu_items, :deadline_types

  def setup
    @controller = SignUpSheetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:admin)
    Role.rebuild_cache
    AuthController.set_current_role(users(:admin).role_id,@request.session)
  end

  test "should_show_add_signup_topics_staggered" do
    get :add_signup_topics_staggered, :id => assignments(:assignment2).id
    assert_response :success
  end

  test "should_create_new_topic_for_assignment" do
    post :create, :topic =>{:topic_identifier=>"t1",:topic_name=>"t1",:category=>"t1",:max_choosers=>3}, :id=>assignments(:assignment2).id
    newTopic = SignUpTopic.find_by_topic_name("t1")
    puts newTopic.assignment_id
    assert_equal(assignments(:assignment2).id,newTopic.assignment_id)
  end

  test "should_delete_signup_topic_for_assignment" do
    post :delete, :id=> sign_up_topics(:topic1).id, :assignment_id => assignments(:assignment2)
    newTopic = SignUpTopic.find_by_assignment_id(assignments(:assignment2).id)
    assert_nil newTopic
  end

  test "should_be_able_to_edit_topics" do
    post :update, :topic =>{:topic_identifier=>"t1",:topic_name=>"t1",:category=>"t1",:max_choosers=>3}, :assignment_id=>assignments(:assignment2).id, :id=>sign_up_topics(:topic1).id
    assert_equal "t1", sign_up_topics(:topic1).topic_name
  end

end
