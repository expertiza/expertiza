require './' + File.dirname(__FILE__) + '/../test_helper'
require 'response_controller'

# Re-raise errors caught by the controller.
class ResponseController; def rescue_action(e) raise e end; end

class ResponseControllerTest < Test::Unit::TestCase
  def setup
    @controller = ResponseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
