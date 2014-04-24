#require File.dirname(__FILE__) + '/../test_helper'
require 'test_helper'
#require 'join_team_requests_controller'

class AdvertiseForPartnerControllerTest < ActionController::TestCase
  fixtures :users, :roles, :teams, :assignments, :nodes, :courses,
           :system_settings, :content_pages, :permissions, :roles_permissions,
           :controller_actions, :site_controllers, :menu_items,
           :participants
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  def setup
    @controller = AdvertiseForPartnerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Role.rebuild_cache
  end

  test "test remove advertisement should set advertise_for_partner false" do
    sessionVars = session_for(users(:student8))
    get(:remove, {'team_id' =>  teams(:IntelligentTeam1).id}, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_false team.advertise_for_partner
  end

  test "test remove advertisement should remove advertisement comments" do
    sessionVars = session_for(users(:student8))
    get(:remove, {'team_id' =>  teams(:IntelligentTeam1).id}, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_nil team.comments_for_advertisement
  end

  test "test remove advertisement should redirect to view" do
    sessionVars = session_for(users(:student8))
    get(:remove, {'team_id' =>  teams(:IntelligentTeam1).id}, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_redirected_to :controller => 'student_team', :action => 'view', :id => participants(:par21).id
  end

  test "test create advertisement should set advertise_for_partner true" do
    sessionVars = session_for(users(:student8))
    post(:create, {'id' =>  teams(:IntelligentTeam1).id, 'comments_for_advertisement' => 'join us' }, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_true team.advertise_for_partner
  end

  test "test create advertisement should set comment for advertisement" do
    sessionVars = session_for(users(:student8))
    post(:create, {'id' =>  teams(:IntelligentTeam1).id, 'comments_for_advertisement' => 'join us' }, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_equal team.comments_for_advertisement, 'join us'
  end

  test "test create advertisement should redirect to view" do
    sessionVars = session_for(users(:student8))
    post(:create, {'id' =>  teams(:IntelligentTeam1).id, 'comments_for_advertisement' => 'join us' }, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_redirected_to :controller => 'student_team', :action => 'view', :id => participants(:par21).id
  end

  test "test update advertisement successfully should show notice" do
    sessionVars = session_for(users(:student8))
    post(:update, {'id' =>  teams(:IntelligentTeam1).id, 'comments_for_advertisement' => 'join us' }, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_equal 'Advertisement updated successfully!', flash[:notice]
  end

  test "test update advertisement successfully should change comment" do
    sessionVars = session_for(users(:student8))
    post(:update, {'id' =>  teams(:IntelligentTeam1).id, 'comments_for_advertisement' => 'join us' }, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_equal team.comments_for_advertisement, 'join us'
  end

  test "test update advertisement successfully should redirect to view" do
    sessionVars = session_for(users(:student8))
    post(:update, {'id' =>  teams(:IntelligentTeam1).id, 'comments_for_advertisement' => 'join us' }, sessionVars, nil)
    team = Team.find_by_id(teams(:IntelligentTeam1).id)
    assert_redirected_to :controller => 'student_team', :action => 'view', :id => participants(:par21).id
  end

  # really cannot come up with a way to make it fail on team.save
  # test "test update advertisement fail" do

  # This will only assign team
  test "test edit advertisement" do
    sessionVars = session_for(users(:student8))
    get(:edit, {'team_id' =>  teams(:IntelligentTeam1).id}, sessionVars, nil)
    assert_equal assigns(:team).id, teams(:IntelligentTeam1).id
  end

end
