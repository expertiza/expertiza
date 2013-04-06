require File.dirname(__FILE__) + '/../test_helper'
require 'auth_controller'

# Re-raise errors caught by the controller.
class AuthController; def rescue_action(e) raise e end; end

class AuthControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    @controller = AuthController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new       
  end

  # Verify that admin accounts are sent to tree_display.
  def test_valid_admin_login
    post :login, :login => {:name => users(:superadmin).name, :password => users(:superadmin).name}
    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])
  end
  
  # Verify that instructor accounts are sent to tree_display.
  def test_valid_instr_login
    post :login, :login => {:name => users(:instructor).name, :password => users(:instructor).name}
    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])
  end 
  
  # Verify that student accounts are sent to student_assignment.
  def test_valid_instr_login
    post :login, :login => {:name => users(:student1).name, :password => users(:student1).name}
    assert_redirected_to :controller => AuthHelper::get_home_controller(session[:user]), :action => AuthHelper::get_home_action(session[:user])
  end    
  
  # Verify that invalid accounts are sent to login failed.
  def test_invalid_account
    post :login, :login => {:name => 'noname', :password => 'badpass'}
    assert_redirected_to :controller => 'password_retrieval', :action => 'forgotten'
  end  
  
# Verify that sign on attempts with incorrect passwords are sent to login failed.  
  def test_invalid_password
    post :login, :login => {:name => 'admin', :password => 'badpass'}
    assert_redirected_to :controller => 'password_retrieval', :action => 'forgotten'
  end  
  
  # Logout should redirect to root location
  def test_logout
    post :login, :login => {:name => users(:superadmin).name, :password => users(:superadmin).name}
    post :logout
    assert_redirected_to '/'
  end  
  
  # Test for accessing an authorized page
  def test_authorized
    post :login, :login => {:name => users(:superadmin).name, :password => users(:superadmin).name}
    params = {:controller => 'impersonate', :action => 'start'}
    assert AuthController.authorised?(@response.session, params)
  end

  # Test for accessing an unauthorized page
  def test_unauthorized
    post :login, :login => {:name => users(:student1).name, :password => users(:student1).name}
    params = {:controller => 'impersonate', :action => 'start'}
    assert_equal AuthController.authorised?(@response.session, params), false    
  end
end