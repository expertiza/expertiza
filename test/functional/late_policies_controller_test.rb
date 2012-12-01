require File.dirname(__FILE__) + '/../test_helper'
require 'controllers/late_policies_controller'

class LatePoliciesControllerTest < ActionController::TestCase
  fixtures :late_policies, :participants, :deadline_types, :due_dates, :assignments, :roles
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings, :users
  @settings = SystemSettings.find(:first)

  def setup
    @controller = LatePoliciesController.new
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

    @policyid= late_policies(:late_policy3).id
  end

  # Test Case 1101
  def test_new
    get :new
  end

  def test_create
    # create a new policy
    #policy = LatePolicy.new(:max_penalty => 50,:policy_name=>"abc",:penalty_per_unit=>4,:instructor_id=>users(:instructor3).id)
    #p flash[:notice].to_s
    post :create, :late_policy => { :max_penalty => '20',:policy_name=>'abc',:penalty_per_unit=>'4'}
    #assert policy.save
  end

  def test_update
    puts users(:instructor3).id
    post :update, :id => @policyid, :late_policy => { :max_penalty => '20',:policy_name=>'abcd',:penalty_per_unit=>'20.0'}
    updatedPolicy = LatePolicy.find_by_id(@policyid)
    assert_equal updatedPolicy.policy_name, "Default Policy 3"
#   assert_nil User.find(:first, :conditions => "name='#{@user.name}'")
#    assert_response :redirect
    #assert_equal '',flash[:error]
    #assert_equal 'Late policy was successfully updated.', flash[:notice]
    #assert_redirected_to :action => 'index'
  end



end