# Tests for ImportFile controller
# Author: ajbudlon
# Date: 7/18/2008

require './' + File.dirname(__FILE__) + '/../test_helper'
require 'import_file_controller'

# Re-raise errors caught by the controller.
class ImportFileController; def rescue_action(e) raise e end; end

class ImportFileControllerTest < ActionController::TestCase
  fixtures :users, :assignments, :roles
  set_fixture_class:system_settings => 'SystemSettings'    
  fixtures :system_settings
  fixtures :content_pages  
  @settings = SystemSettings.find(:first)
  
  def setup
    @controller = ImportFileController.new
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

  def test_start
    post :start, :model => 'Participant', 
                 :expected_fields => 'foo',
                 :title => 'Foo Import',
                 :id => assignments(:assignment1).id
    assert_response :success
  end 
  
  def test_import
    partcount = AssignmentParticipant.count  
    @request.session[:return_to] = 'http://test:host'
    post :import, :model => 'AssignmentParticipant',
                  :file => File.new(RAILS_ROOT+'/test/roster.txt'),
                  :id => assignments(:assignment1).id,
                  :delim_type => 'other',
                  :other_char => '*'
   assert partcount+1, AssignmentParticipant.count                  
   assert_redirected_to 'http://test:host'                
  end
end