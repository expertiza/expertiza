# This functional test, tests functions associated with instructor
# It includes check for list , show and remove of an instructor.
#require File.dirname(__FILE__) + '/../test_helper'
#require 'instructor_controller'
require 'test_helper'

# Re-raise errors caught by the controller.
class InstructorController; def rescue_action(e) raise e end; end

class InstructorControllerTest < ActionController::TestCase
  fixtures :users, :roles, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items
  set_fixture_class :system_settings => 'SystemSettings' 
  set_fixture_class :roles_permissions => 'RolesPermission'

  # Check listing of instructors by a super-admin
  def test_list_instr_valid_super
    post :list, nil, session_for(users(:superadmin))
    assert_response :success
  end

  # Check listing of instructors by a admin
  def test_list_instr_valid_admin
    post :list, nil, session_for(users(:admin))
    assert_response :success
  end

  # Check listing of instructors by a student
  def test_list_instr_invalid
    @settings = SystemSettings.find(system_settings(:first).id)
    post :list, nil, session_for(users(:student1))
    assert_redirected_to '/denied'
  end

  # Check a particular instructor by administrator
  def test_show_instr
    post :show,{:id => users(:instructor1).id}, session_for(users(:admin))
    assert_response  :success
  end

  # Remove a particular instructor by administrator
  def test_remove_instr
    post :remove,{ :id => users(:instructor2).id }, session_for(users(:admin))
    assert_redirected_to '/instructor/list'
  end

end
