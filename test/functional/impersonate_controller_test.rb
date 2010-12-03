# Tests for Impersonate controller
# Author: ajbudlon
# Date: 7/18/2008

require 'test_helper'
require 'impersonate_controller'

# Re-raise errors caught by the controller.
class ImpersonateController; def rescue_action(e) raise e end; end

class ImpersonateControllerTest < Test::Unit::TestCase
  fixtures :users

  
  def setup
    @controller = ImpersonateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new   
    @request.session[:user] = users(:superadmin)
    AuthController.set_current_role(users(:superadmin).role_id,@request.session)
  end
  
  def test_start
    post :start
    assert_response :success
  end

  def test_impersonate
    post :impersonate, :user => {:name => users(:student).name}
    #verify that current user is student
    assert_equal users(:student).id, session[:user].id
    #verify that stored user is superadmin
    assert_equal users(:superadmin).id, session[:super_user].id
    
    assert_redirected_to :action => AuthHelper::get_home_action(users(:student)), 
                    :controller => AuthHelper::get_home_controller(users(:student))
  end
  
  def test_fail_impersonate
    @request.env['HTTP_REFERER'] = "http://localhost:3000"
    post :impersonate, :user => {:name => 'blah'}
    assert_equal "No user exists with the name 'blah'", flash[:error]
    assert_redirected_to "http://localhost:3000"
  end
  
  def test_restore
    post :impersonate, :user => {:name => users(:student).name}
    assert !session[:super_user].nil?
    post :restore
    assert session[:super_user].nil?
    assert_equal users(:superadmin).id, session[:user].id
    assert_redirected_to :action => AuthHelper::get_home_action(users(:superadmin)), 
                    :controller => AuthHelper::get_home_controller(users(:superadmin))

  end
end