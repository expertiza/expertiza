require File.dirname(__FILE__) + '/../test_helper'
require 'publishing_controller'

# Re-raise errors caught by the controller.
class PublishingController; def rescue_action(e) raise e end; end

class PublishingControllerTest < Test::Unit::TestCase
  fixtures :users, :roles, :participants

  def setup
    @controller = PublishingController.new  
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:student1).id)
    Role.rebuild_cache
    AuthController.set_current_role(User.find(users(:student1).id).role_id,@request.session)
  end
  
  def test_grant
    get :grant, :id => users(:student1).id
    assert_response :success     
  end
end
