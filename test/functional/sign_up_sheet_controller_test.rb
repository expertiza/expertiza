require 'test_helper'
require 'ruby-debug'
require 'signup_controller'

class SignUpSheetController; def rescue_action(e) raise e end; end

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



  #create new sign_up_topic for a microtask assignment
  def test_new_microtask_topic

    @controller = SignUpSheetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:instructor3).id )
    roleid = User.find(users(:instructor3).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
    #   @request.session[:user] = User.find_by_name("suadmin")

    assignment_id = Assignment.find(:all, :conditions => "name = 'assignment_microtask1'").id
    # create a new sign_up_topic for microtask assignment
    post :create, :assignment => {
      :topic_name => "mt_topic_test",
      :topic_identifier => "mt_topic_identifier",
      :maxchooser => 2,
      :category => "mt_topic_category",
      :assignment_id => assignment_id,
      :micropayment => 2 }

    assert_response :redirect
    assert SignUpTopic.find(:all, :conditions => ["topic_name = 'mt_topic_test' AND micropayment = 2"])
  end

end

