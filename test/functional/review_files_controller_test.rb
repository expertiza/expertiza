require 'test_helper'
require 'review_files_controller'


class ReviewFilesControllerTest < ActionController::TestCase
  fixtures :users, :participants
  def setup
    @controller = ReviewFilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:admin)
    Role.rebuild_cache
    AuthController.set_current_role(users(:admin).role_id,@request.session)
  end

  test "should_list_submitted_files" do
    get :show_all_submitted_files, :participant_id => participants(:par1).id
    assert_response :success
  end
end