require File.dirname(__FILE__) + '/../test_helper'
require 'controllers/late_policies_controller'

# Re-raise errors caught by the controller.
class LatePoliciesController; def rescue_action(e) raise e end; end

class LatePoliciesControllerTest < ActionController::TestCase
  fixtures :late_policies, :participants, :deadline_types, :due_dates, :assignments, :roles
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings, :users
  @settings = SystemSettings.find(:first)

  def setup
    @controller = LatePoliciesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:admin).id )
    roleid = User.find(users(:admin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)

  end


  def test_update
    put :update, post => { :id=>late_policies(:late_policy3).id,:max_penalty => 50,:policy_name=>"abc",:penalty_per_unit=>4 }
    assert_redirected_to post_path(assigns(:late_policy))
  end

  def test_view
    get :index
    assert_response :success
    #assert_not_nil assigns(:penalty_policies)
  end

end