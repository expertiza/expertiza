require 'test_helper'

class SignUpSheetControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  # fixtures :sign_up_topics, :assignments, :signed_up_users, :users, :roles, :due_dates
  # fixtures :site_controllers, :content_pages, :roles_permissions, :participants
  # fixtures :controller_actions, :permissions, :system_settings, :menu_items, :deadline_types

  def setup
    @admin = users(:admin)
    @student1 = users(:student1)
    @assignment2 = assignments(:assignment2)
  end

  test "admin should view index" do
    set_user @admin

    get :index, :id => @assignment2
    assert_response :success
  end

  test "admin should create new topic for assignment" do
    set_user @admin

    get :create,
        :topic => {
          :topic_identifier=>"t1",
          :topic_name=>"t1",
          :category=>"t1",
          :max_choosers=>3
        }, :id => @assignment2
    assert_redirected_to :action => :index, :id => @assignment2

    assert_not_nil SignUpTopic.find_by_topic_name("t1")
  end

  # test "should_delete_signup_topic_for_assignment" do
  #   post :destroy, :id=> sign_up_topics(:Topic1).id, :assignment_id => assignments(:assignment_project1)
  #   newTopic = SignUpTopic.find_by_assignment_id(assignments(:assignment_project1).id)
  #   assert_nil newTopic
  # end

  # test "should_be_able_to_edit_topics" do
  #   post :update, :topic =>{:topic_identifier=>"t1",:topic_name=>"t1",:category=>"t1",:max_choosers=>3}, :assignment_id=>assignments(:assignment_project1).id, :id=>sign_up_topics(:Topic1).id
  #   assert_equal "Topic1", sign_up_topics(:Topic1).topic_name
  # end

  # #create new sign_up_topic for a microtask assignment
  # def test_new_microtask_topic
  #
  #   @controller = SignUpSheetController.new
  #   @request    = ActionController::TestRequest.new
  #   @response   = ActionController::TestResponse.new
  #
  #   @request.session[:user] = User.find(users(:instructor3).id )
  #   roleid = User.find(users(:instructor3).id).role_id
  #   Role.rebuild_cache
  #
  #   Role.find(roleid).cache[:credentials]
  #   @request.session[:credentials] = Role.find(roleid).cache[:credentials]
  #   # Work around a bug that causes session[:credentials] to become a YAML Object
  #   @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
  #   @settings = SystemSettings.find(:first)
  #   AuthController.set_current_role(roleid,@request.session)
  #   #   @request.session[:user] = User.find_by_name("suadmin")
  #
  #   assignment_id = assignments(:assignment_microtask1).id
  #   # create a new sign_up_topic for microtask assignment
  #   post :create, :topic => {
  #     :topic_name => "mt_topic_test",
  #     :topic_identifier => "mt_topic_identifier",
  #     :max_choosers => 2,
  #     :category => "mt_topic_category",
  #     :assignment_id => assignment_id,
  #     :micropayment => 2 } , :id => assignment_id
  #
  #   assert_response :redirect
  #   assert SignUpTopic.find(:all, :conditions => ["topic_name = 'mt_topic_test' AND micropayment = 2"])
  # end

  test "student should view signup index" do
    set_user @student1

    get :index_signup, :id => @assignment2
    assert_response :success
  end

  # test "student should sign up for topic" do
  #   set_user @student1
  #
  #   get :create_signup, :id => @topic1, :assignment_id => @assignment2
  #   assert_redirected_to :action => :index_signup, :id => @assignment2
  # end

private
  # Sets the user for the current session
  def set_user(user)
    session[:user] = user
  end

end
