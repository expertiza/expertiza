# Tests for ImportFile controller
# Author: ajbudlon
# Date: 7/18/2008

require File.dirname(__FILE__) + '/../test_helper'
require 'import_file_controller'

# Re-raise errors caught by the controller.
class ImportFileController; def rescue_action(e) raise e end; end

class ImportFileControllerTest < Test::Unit::TestCase
  fixtures :users, :assignments

  
  def setup
    @controller = ImportFileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new   
    @request.session[:user] = users(:superadmin)
    AuthController.set_current_role(users(:superadmin).role_id,@request.session)
  end

  def test_start
    post :start, :model => 'Participant', 
                 :expected_fields => 'foo',
                 :title => 'Foo Import',
                 :id => assignments(:first).id
    assert_response :success              
  end 
  
  def test_import
    partcount = AssignmentParticipant.count  
    @request.session[:return_to] = 'http://localhost:3000'
    post :import, :model => 'AssignmentParticipant',
                  :file => File.new(RAILS_ROOT+'/test/roster.txt'),
                  :id => assignments(:first).id,
                  :delim_type => 'other',
                  :other_char => '*'                 
   assert partcount+1, AssignmentParticipant.count                  
   assert_redirected_to 'http://localhost:3000'                
  end
end