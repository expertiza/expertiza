# Tests for ExportFile controller
# Author:
# Date:

require File.dirname(__FILE__) + '/../test_helper'
require 'export_file_controller'

# Re-raise errors caught by the controller.
class ExportFileController; def rescue_action(e) raise e end; end

class ExportFileControllerTest < ActionController::TestCase
  fixtures :courses,:users, :roles, :system_settings, :content_pages, :permissions, :roles_permissions, :controller_actions, :site_controllers, :menu_items, :assignments, :participants
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings
  fixtures :content_pages
  @settings = SystemSettings.find(:first)

  def setup
    @controller             = ExportFileController.new
    @request                = ActionController::TestRequest.new
    @response               = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:admin).id )
    roleid                  = User.find(users(:admin).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
  end
  def test_start
    post :start, :model           => 'User',
                 :id              => assignments(:assignment1).id
    assert_response :success
  end
  def test_export_users
    options_test = Hash.new
    options_test[:personal_details] = "true"
    options_test[:role] = "true"
    options_test[:parent] = "true"
    options_test[:email_options] = "true"
    options_test[:handle] = "true"
    @request.session[:return_to] = 'http://test:host'
    post :export, :model => 'User',
                  :delim_type => 'comma',
                  :id => 1,
                  :options => options_test
    assert_response :success
  end
  def test_export_grades
    @request.session[:return_to] = 'http://test:host'
    options_test = Hash.new
    options_test[:team_score] = "true"
    options_test[:submitted_score] = "true"
    options_test[:author_feedback_score] = "true"
    options_test[:metareview_score] = "true"
    options_test[:teammate_review_score] = "true"

    post :export, :model => 'Assignment',
                  :delim_type => 'comma',
                  :id => assignments(:assignment1).id,
                  :options => options_test
    assert_response :success
  end
  def test_export_course_participants
    options_test = Hash.new
    options_test[:personal_details] = "true"
    options_test[:role] = "true"
    options_test[:parent] = "true"
    options_test[:email_options] = "true"
    options_test[:handle] = "true"
    @request.session[:return_to] = 'http://test:host'
    post :export, :model => 'CourseParticipant',
         :delim_type => 'comma',
         :id => 1,
         :options => options_test
    assert_response :success
  end
  def test_export_assignment_team
    options_test = Hash.new
    options_test[:personal_details] = "true"
    options_test[:role] = "true"
    options_test[:parent] = "true"
    options_test[:email_options] = "true"
    options_test[:handle] = "true"
    post :export, :model => 'AssignmentTeam',
         :delim_type => 'comma',
         :id => assignments(:assignment1).id,
         :options => options_test
    assert_response :success
  end
  def test_export_course_team
    options_test = Hash.new
    options_test[:personal_details] = "true"
    options_test[:role] = "true"
    options_test[:parent] = "true"
    options_test[:email_options] = "true"
    options_test[:handle] = "true"
    post :export, :model => 'CourseTeam',
         :delim_type => 'comma',
         :id => courses(:course1).id,
         :options => options_test
    assert_response :success
  end
end