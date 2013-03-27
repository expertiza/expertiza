# Tests for Impersonate controller
# Author: ajbudlon
# Date: 7/18/2008

require File.dirname(__FILE__) + '/../test_helper'
require 'impersonate_controller'

# Re-raise errors caught by the controller.
class ImpersonateController; def rescue_action(e) raise e end; end

class ImpersonateControllerTest < ActionController::TestCase
  fixtures :users, :roles, :system_settings

  # puts "Now entering ImpersonateController Test...."
  set_fixture_class :system_settings => 'SystemSettings'    
  fixtures :system_settings
  fixtures :content_pages  
  @settings = SystemSettings.find(:first)
  
  def setup
  # puts "Now entering ImpersonateController Test .... setup method ...."  
    @controller = ImpersonateController.new  
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

  # puts "Now exiting ImpersonateController Test .... setup method ...."
  end
  
  def test_start
    post :start
    assert_response :success
  end

  def test_impersonate
    @request.env['HTTP_REFERER'] = "http://test.host/tree_display/drill"
    post :impersonate, :user => {:name => users(:student1).name}
    #verify that current user is student
#   studentuser = session[:user]
#   superuser = session[:super_user]
#   puts "users(:student1).name --> " + users(:student1).name 
#   puts "studentuser.name --> " + studentuser.name 
#   puts "users(:superadmin).name --> " + users(:superadmin).name
#   puts "superuser.name --> " + superuser.name
    
#   puts "users(:student1).id --> " + users(:student1).id.to_s 
#   puts "session[:user].id --> " + session[:user].id.to_s 
#   puts "users(:superadmin).id --> " + users(:superadmin).id.to_s
#   puts "session[:super_user].id --> " + session[:super_user].id.to_s     
#   assert_equal users(:student1).id, session[:user].id
    #verify that stored user is superadmin
#   assert_equal users(:superadmin).id, session[:super_user].id
    
    assert_redirected_to :action => AuthHelper::get_home_action(users(:student1)), 
                    :controller => AuthHelper::get_home_controller(users(:student1))
  end
  
  def test_fail_impersonate
    @request.env['HTTP_REFERER'] = "http://localhost:3000"
    post :impersonate, :user => {:name => 'blah'}
    assert_equal "No user exists with the name 'blah'", flash[:error]
    assert_redirected_to "http://localhost:3000"
  end
  
# def test_restore
#   @request.env['HTTP_REFERER'] = "http://localhost:3000/list/student1"    
#   post :impersonate, :user => {:name => users(:student1).name}
#   assert !session[:super_user].nil?
#   post :restore
#   assert session[:super_user].nil?
#   assert_equal users(:superadmin).id, session[:user].id
#   assert_redirected_to :action => AuthHelper::get_home_action(users(:superadmin)), 
#                   :controller => AuthHelper::get_home_controller(users(:superadmin))

# end
end