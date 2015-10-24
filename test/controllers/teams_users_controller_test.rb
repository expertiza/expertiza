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
    post :create, user: {name: users(:student1).name}, 'id'=>1
    assert_not_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_two_members" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student1).name}, 'id'=>1
    post :create, user: {name: users(:student2).name}, 'id'=>1
    assert_not_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_three_members" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student1).name}, 'id'=>1
    post :create, user: {name: users(:student2).name}, 'id'=>1
    post :create, user: {name: users(:student3).name}, 'id'=>1
    assert_not_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_four_members" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student1).name}, 'id'=>1
    post :create, user: {name: users(:student2).name}, 'id'=>1
    post :create, user: {name: users(:student3).name}, 'id'=>1
    post :create, user: {name: users(:student4).name}, 'id'=>1
    assert_equal "The team already has the maximum number of members.", flash[:error]

  end

  test "add_participant_to_team" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student1).name}, 'id'=>1
    url = "http://test.host/participants/list?authorization=participant&id=1&model=Assignment"
    assert_not_equal "\"student1\" is not a participant of current assignment. Please <a href=\"#{url}\">add</a> this user before continuing.", flash[:error]
  end

  test "add_non_participant_to_team" do
    @request.session[:user] = User.find(users(:instructor1).id)
    user = User.find(users(:instructor1).id)
    post :create, user: {name: users(:student7).name}, 'id'=>1
    url = "http://test.host/participants/list?authorization=participant&id=1&model=Assignment"
    assert_equal "\"student7\" is not a participant of current assignment. Please <a href=\"#{url}\">add</a> this user before continuing.", flash[:error]
  end


end

