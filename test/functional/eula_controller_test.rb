require './' + File.dirname(__FILE__) + '/../test_helper'
require 'eula_controller'

# Re-raise errors caught by the controller.
class EulaController; def rescue_action(e) raise e end; end

class EulaControllerTest < ActiveSupport::TestCase
  def setup
    @controller = EulaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
