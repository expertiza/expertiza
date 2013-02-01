#require File.dirname(__FILE__) + '/../test_helper'
#require 'admin_controller'
require 'test_helper'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < ActionController::TestCase
  fixtures :users, :roles, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items
  set_fixture_class :system_settings => 'SystemSettings' 
  set_fixture_class :roles_permissions => 'RolesPermission'
  
  # Check listing of super-administrators by a super-admin
  def test_list_superadmin_valid
    post :list_super_administrators, nil, session_for(users(:superadmin))
    assert_response :success
  end
  
  # Check listing of super-administrators by a student  
  def test_list_superadmin_invalid
    @settings = SystemSettings.find(system_settings(:first).id)    
    post :list_super_administrators, nil, session_for(users(:student1))
    assert_redirected_to '/denied'
  end    

  # Check listing of administrators by a super-admin
  def test_list_admin_valid
    post :list_administrators, nil, session_for(users(:superadmin))
    assert_response :success    
  end
  
  # Check listing of administrators by a student  
  def test_list_admin_invalid
    @settings = SystemSettings.find(system_settings(:first).id)
    post :list_administrators, nil, session_for(users(:student1))
    assert_redirected_to '/denied' 
  end     
  
  # Check listing of instructors by a super-admin   
  def test_list_instr_valid
    post :list_instructors, nil, session_for(users(:superadmin))
    assert_response :success  
  end
  
  # Check listing of instructors by a student
  def test_list_instr_invalid
    @settings = SystemSettings.find(system_settings(:first).id)
    post :list_instructors, nil, session_for(users(:student1))
    assert_redirected_to '/denied' 
  end     
end
