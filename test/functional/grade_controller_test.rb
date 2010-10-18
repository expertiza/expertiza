require File.dirname(__FILE__) + '/../test_helper'
require 'grades_controller'

# Re-raise errors caught by the controller.
class GradesController; def rescue_action(e) raise e end; end

class GradesControllerTest < Test::Unit::TestCase
  fixtures :participants, :assignments
  
  def setup
    @controller = GradesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = true
    @request.session[:user] = User.find(users(:superadmin).id)
    AuthController.set_current_role(User.find(users(:superadmin).id).role_id,@request.session)    
  end
  
  def test_update 
    post :update, :id => participants(:part1).id, :participant => {:grade => '100'}
    assert_equal 100,participants(:part1).grade
  end
  
  def test_view
    post :view, :id => assignments(:first).id
    assert_response :success
  end
  
end