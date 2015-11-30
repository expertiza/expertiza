require File.dirname(__FILE__) + '/../test_helper'

class SubmittedContentControllerTest < ActionController::TestCase
  fixtures :courses, :teams, :users, :teams_users, :participants, :assignments, :nodes, :roles, :deadline_types

  def setup
    @controller = SubmittedContentController.new
    @request = ActionController::TestRequest.new
    @request_student2 = ActionController::TestRequest.new
    @response_student1 = ActionController::TestResponse.new
    @response_student2 = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:student1).id)
    @request_student2.session[:user] = User.find(users(:student2).id)
  end

  test "submit Hyperlink for student1" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.google.com'
    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 1,list_of_hyperLinks.count
  end

  test "submit Hyperlink for student1 and student2" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'

    @request.session[:user] = User.find(users(:student2).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.ncsu.edu'

    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 2,list_of_hyperLinks.count
  end

  test "submit same hyperlink twice" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'

    @request.session[:user] = User.find(users(:student2).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'

    assert_equal "You or your teammate(s) have already submitted the same hyperlink.", flash[:error]

    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 1,list_of_hyperLinks.count
  end

  test "remove hyperlink" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.google.com'
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.ncsu.edu'

    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 3,list_of_hyperLinks.count

    post :remove_hyperlink, :hyperlinks => { :participant_id => participants(:participant1).id} , :chk_links => '1'
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 2,list_of_hyperLinks.count
  end

  # test "student submits a hyperlink, instructor can view the hyperlink" do
  #   @request.session[:user] = User.find(users(:student1).id)
  #   post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'
  #
  #   @request.session[:user] = User.find(users(:instructor1).id)
  #   post :
  # end
end