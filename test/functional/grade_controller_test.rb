require File.dirname(__FILE__) + '/../test_helper'
require 'grades_controller'

# Re-raise errors caught by the controller.
class GradesController; def rescue_action(e) raise e end; end

class GradesControllerTest < ActionController::TestCase
  fixtures :participants, :deadline_types, :due_dates, :assignments, :roles
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings, :content_pages, :users, :due_dates
  @settings = SystemSettings.find(:first)
  
  def setup
    @controller = GradesController.new    
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
    post :update, :id => participants(:par1).id, :participant => {:grade => '95'}, :total_score => 100
    participant = AssignmentParticipant.find(participants(:par1).id)    
#   assert_equal 95,participants(:par1).grade
    assert_equal 95,participant.grade
  end
  
  def test_view
    post :view, :id => assignments(:assignment1).id
    assert_response :success
  end
  
end