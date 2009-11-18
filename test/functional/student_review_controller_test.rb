require File.dirname(__FILE__) + '/../test_helper'
require 'student_review_controller'

# Re-raise errors caught by the controller.
class StudentReviewController; def rescue_action(e) raise e end; end

class StudentReviewControllerTest < Test::Unit::TestCase
  def setup
    @controller = StudentReviewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
