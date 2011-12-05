require File.dirname(__FILE__) + '/../test_helper'
require 'sign_up_sheet_controller'

# Re-raise errors caught by the controller.
class SignUpSheetController; def rescue_action(e) raise e end; end

class SignUpSheetControllerTest < ActionController::TestCase
  fixtures :users
  fixtures :assignments
 # fixtures :sign_up_topics
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
  end

  #create new sign_up_topic for a microtask assignment
  def test_new_microtask_topic

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

