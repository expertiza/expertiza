require File.dirname(__FILE__) + '/../test_helper'
require 'pg_users_controller'

# Re-raise errors caught by the controller.
class PgUsersController; def rescue_action(e) raise e end; end

class PgUsersControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    @controller = PgUsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:superadmin).id)
    AuthController.set_current_role(User.find(users(:superadmin).id).role_id,@request.session)
  end

  
end
