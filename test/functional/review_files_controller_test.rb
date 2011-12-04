require 'test_helper'
require 'review_files_controller'
require 'review_comments_helper'


class ReviewFilesControllerTest < ActionController::TestCase
  fixtures :users, :participants, :review_files
  def setup
    @controller = ReviewFilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:student1)
    Role.rebuild_cache
    AuthController.set_current_role(users(:student1).role_id,@request.session)
  end


  test "show_all_submitted_files" do
    get :show_all_submitted_files, :participant_id => participants(:par1).id,
        :stage =>"submission"
    assert_response :success
  end

  test "show_code_file_contents" do
    @versions = ReviewFile.find_all_by_id(review_files(:one))
    @file_versions = Array.new
    @versions.each  do |ver|
      @file_versions << ver.version_number
    end
    get :show_code_file, :participant_id => participants(:par1).id,
        :review_file_id => review_files(:one).id, :versions=>@file_versions
    assert_response :success
  end

  test "show_code_file_diff" do
    @versions = ReviewFile.find_all_by_id(review_files(:one))
    @file_versions = Array.new
    @versions.each  do |ver|
      @file_versions << ver.version_number
    end
    get :show_code_file_diff, :participant_id => participants(:par1).id,
        :current_version_id => 2, :diff_with_file_id => 1,
        :versions =>@file_versions
    assert_response :success
  end

  test "should_submit_comment" do
    get :submit_comment, :file_id => review_files(:one).id, :file_offset => 0,
        :comment_content => "test comment"
    assert_response :success
    @comment_check = ReviewComment.find_by_comment_content_and_review_file_id(
        "test comment",review_files(:one).id)
    assert_not_nil(@comment_check)
  end

  test "should_get_comments" do
    get :get_comments, :file_is => review_files(:one).id, :file_offset => 0
    @comments = ReviewComment.find_by_file_offset_and_review_file_id(
        0,review_files(:one).id)
    comment_table = ReviewCommentsHelper::construct_comments_table(@comments)
    assert_response comment_table
    assert_response :success
  end

end