require 'test_helper'
require 'export_file_controller'

# Re-raise errors caught by the controller.
class ExportFileController; def rescue_action(e) raise e end; end

class ExportFileControllerTest < Test::Unit::TestCase
  def setup
    @controller = ExportFileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
