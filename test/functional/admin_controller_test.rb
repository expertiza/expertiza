require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new      
  end
  
  # Check listing of super-administrators by a super-admin
  def test_list_superadmin_valid
    @request.session[:user] = User.find(users(:superadmin).id)
    AuthController.set_current_role(User.find(users(:superadmin).id).role_id,@request.session)
    
    post :list_administrators
    assert_response :success  
    admin_role = Role.find_by_name("Super-Administrator")
    admin_users = User.find(:all, :conditions => ['role_id = ?',admin_role.id])
    assert_equal admin_users.size, assigns["users"].size        
  end
  
  # Check listing of super-administrators by a student  
  def test_list_superadmin_invalid
    @request.session[:user] = User.find(users(:student).id)
    AuthController.set_current_role(User.find(users(:student).id).role_id,@request.session)
    
    post :list_administrators
    assert_redirected_to '/denied' 
  end    

  # Check listing of administrators by a super-admin
  def test_list_admin_valid
    @request.session[:user] = User.find(users(:superadmin).id)
    AuthController.set_current_role(User.find(users(:superadmin).id).role_id,@request.session)
    
    post :list_administrators
    assert_response :success  
    admin_role = Role.find_by_name("Administrator")
    admin_users = User.find(:all, :conditions => ['role_id = ?',admin_role.id])
    assert_equal admin_users.size, assigns["users"].size        
  end
  
  # Check listing of administrators by a student  
  def test_list_admin_invalid
    @request.session[:user] = User.find(users(:student).id)
    AuthController.set_current_role(User.find(users(:student).id).role_id,@request.session)
    
    post :list_administrators
    assert_redirected_to '/denied' 
  end     
  
  # Check listing of instructors by a super-admin   
  def test_list_instr_valid
    @request.session[:user] = User.find(users(:superadmin).id)
    AuthController.set_current_role(User.find(users(:superadmin).id).role_id,@request.session)
    
    post :list_instructors
    assert_response :success  
    admin_role = Role.find_by_name("Instructor")
    admin_users = User.find(:all, :conditions => ['role_id = ?',admin_role.id])
    assert_equal admin_users.size, assigns["users"].size        
  end
  
  # Check listing of instructors by a student
  def test_list_instr_invalid
    @request.session[:user] = User.find(users(:student).id)
    AuthController.set_current_role(User.find(users(:student).id).role_id,@request.session)
    
    post :list_administrators
    assert_redirected_to '/denied' 
  end     
end
