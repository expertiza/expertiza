require './' + File.dirname(__FILE__) + '/../test_helper'
require 'student_tasks_controller'

# Re-raise errors caught by the controller.
class StudentTasksController; def rescue_action(e) raise e end; end

class StudentTasksControllerTest < Test::Unit::TestCase
  def setup
    @controller = StudentTasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
