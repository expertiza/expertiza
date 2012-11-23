require 'test_helper'
require 'ruby-debug'
require 'signup_controller'


class SignupControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  fixtures :sign_up_topics, :assignments, :signed_up_users, :users, :roles, :due_dates
  fixtures :site_controllers, :content_pages, :roles_permissions, :participants
  fixtures :controller_actions, :permissions, :system_settings, :menu_items, :deadline_types

  def setup
    @controller = SignupController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:student5)
    Role.rebuild_cache
    AuthController.set_current_role(users(:student5).role_id,@request.session)
  end

  test "should_be_able_to_view_signup_topics" do
    get :signup_topics, :id => assignments(:assignment2).id
    assert_response :success
  end

  test "should_be_able_to_signup_for_topic" do
    get :delete_signup, {:id => sign_up_topics(:Topic1).id,:assignment_id => assignments(:assignment_project1).id }
    assert_response :redirect
    get :signup, {:id => sign_up_topics(:Topic1).id,:assignment_id => assignments(:assignment_project1).id }
    assert_equal(sign_up_topics(:Topic1).id, participants(:par17).topic_id)
    assert_redirected_to :action => "signup_topics", :id =>  assignments(:assignment_project1).id
  end

  test "should_be_able_to_drop_topic" do
    get :delete_signup, {:id => sign_up_topics(:Topic1).id,:assignment_id => assignments(:assignment_project1).id }
    assert_redirected_to :action => "signup_topics", :id =>  assignments(:assignment_project1).id
  end

end
