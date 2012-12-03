require File.dirname(__FILE__) + '/../test_helper'
require 'sign_up_sheet_controller'

# Re-raise errors caught by the controller.
class SignUpSheetController; def rescue_action(e) raise e end; end

class SignUpSheetControllerTest < ActionController::TestCase
  fixtures :users
  fixtures :assignments
  fixtures :sign_up_topics
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  def setup
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
    @assignment = assignments(:assignment_microtask1)
    @topic = sign_up_topics(:Topic4)
  end

  #Updated in reference wrt E702
  #default sign_up_topic for a microtask assignment
  def test_default_microtask_topic
    # create a new sign_up_topic for microtask assignment
    post :create_default_for_microtask, :id => @assignment.id , :assignment_weight => 0
    #assert_response :redirect
    assert_redirected_to "/sign_up_sheet/add_signup_topics/"+@assignment.id.to_s
    assert SignUpTopic.find(:all, :conditions => ["topic_name = 'mt_topic_test' AND micropayment = 2"])
  end

  #create new sign_up_topic for a microtask assignment
  def test_new_microtask_topic
    # create a new sign_up_topic for microtask assignment
    get :new, :id => @assignment.id
    assert_select "title","sign_up_sheet | new"
    assert_template :new
    post :create , :id => @assignment.id , :topic_weight => 1 ,:topic => {
    :topic_name => "mt_topic_test2" ,
    :assignment_id =>  @assignment.id ,
    :max_choosers => 3 ,
    :topic_identifier => "A106" ,
    :micropayment => 2}

    assert_response :redirect
    assert_redirected_to "/sign_up_sheet/add_signup_topics/"+@assignment.id.to_s
    assert SignUpTopic.find(:all, :conditions => ["topic_name = 'mt_topic_test2' AND micropayment = 2"])
  end
end

