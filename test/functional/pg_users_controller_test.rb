require File.dirname(__FILE__) + '/../test_helper'
require 'pg_users_controller'

# Re-raise errors caught by the controller.
class PgUsersController; def rescue_action(e) raise e end; end

class PgUsersControllerTest < Test::Unit::TestCase
  def setup
    @controller = PgUsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
