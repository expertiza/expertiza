require 'test_helper'
require 'publishing_controller'

# Re-raise errors caught by the controller.
class PublishingController; def rescue_action(e) raise e end; end

class PublishingControllerTest < Test::Unit::TestCase
  def setup
    @controller = PublishingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
