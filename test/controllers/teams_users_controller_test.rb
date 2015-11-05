require 'test_helper'


class TeamsUsersControllerTest < ActionController::TestCase
  fixtures :users, :assignments, :teams, :roles, :nodes, :participants

  def setup
    @controller = TeamsUsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = User.find(users(:instructor1).id)
  end


  test "add_one_member" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student8).name}, 'id'=>4
    assert_not_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_two_members" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student8).name}, 'id'=>4
    post :create, user: {name: users(:student9).name}, 'id'=>4
    assert_not_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_three_members" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student8).name}, 'id'=>4
    post :create, user: {name: users(:student9).name}, 'id'=>4
    post :create, user: {name: users(:student10).name}, 'id'=>4
    assert_not_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_four_members" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student8).name}, 'id'=>4
    post :create, user: {name: users(:student9).name}, 'id'=>4
    post :create, user: {name: users(:student10).name}, 'id'=>4
    post :create, user: {name: users(:student11).name}, 'id'=>4
    assert_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_participant_to_team" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student8).name}, 'id'=>4
    url = "http://test.host/participants/list?authorization=participant&id=1&model=Assignment"
    assert_not_equal "\"student8\" is not a participant of current assignment. Please <a href=\"#{url}\">add</a> this user before continuing.", flash[:error]
  end

  test "add_non_participant_to_team" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student12).name}, 'id'=>4
    url = "http://test.host/participants/list?authorization=participant&id=1&model=Assignment"
    assert_equal "\"student12\" is not a participant of current assignment. Please <a href=\"#{url}\">add</a> this user before continuing.", flash[:error]
  end


end

