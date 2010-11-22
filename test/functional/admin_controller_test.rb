require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  fixtures :users, :roles, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items
  set_fixture_class :system_settings => 'SystemSettings' 
  set_fixture_class :roles_permissions => 'RolesPermission'
  
  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new      
  end
  
  # Check listing of super-administrators by a super-admin
  def test_list_superadmin_valid
    @request.session[:user] = User.find(users(:superadmin).id)
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
    
    post :list_super_administrators
    assert_response :success     
  end
  
  # Check listing of super-administrators by a student  
  def test_list_superadmin_invalid
    @request.session[:user] = User.find(users(:student1).id)
    
    roleid = User.find(users(:student1).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
    
    @settings = SystemSettings.find(system_settings(:first).id)
    
    post :list_super_administrators
    assert_redirected_to '/denied' 
  end    

  # Check listing of administrators by a super-admin
  def test_list_admin_valid
    @request.session[:user] = User.find(users(:superadmin).id)
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
    
    post(:list_administrators)
    assert_response :success    
  end
  
  # Check listing of administrators by a student  
  def test_list_admin_invalid
    @request.session[:user] = User.find(users(:student1).id)
    roleid = User.find(users(:student1).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
    
    @settings = SystemSettings.find(system_settings(:first).id)

    post :list_administrators
    assert_redirected_to '/denied' 
  end     
  
  # Check listing of instructors by a super-admin   
  def test_list_instr_valid
    @request.session[:user] = User.find(users(:superadmin).id)
    roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
    
    post :list_instructors
    assert_response :success  
  end
  
  # Check listing of instructors by a student
  def test_list_instr_invalid
    @request.session[:user] = User.find(users(:student1).id)
    
    roleid = User.find(users(:student1).id).role_id
    Role.rebuild_cache
    Role.find(roleid).cache[:credentials]
    AuthController.set_current_role(roleid,@request.session)
    
    @settings = SystemSettings.find(system_settings(:first).id)
    
    post :list_instructors
    assert_redirected_to '/denied' 
  end     
end
