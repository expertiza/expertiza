require 'test_helper'
require 'student_team_controller'

class StudentTeamControllerTest < ActionController::TestCase

  fixtures :users, :roles, :teams, :assignments, :nodes, :courses,
           :system_settings, :content_pages, :permissions, :roles_permissions,
           :controller_actions, :site_controllers, :menu_items,
           :participants
  set_fixture_class :system_settings => 'SystemSettings'
  set_fixture_class :roles_permissions => 'RolesPermission'

  def setup
    @controller = StudentTeamController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #@request.session[:user] = User.find(users(:superadmin).id )
    #roleid = User.find(users(:superadmin).id).role_id
    Role.rebuild_cache
    #Role.find(roleid).cache[:credentials]
    #@request.session[:credentials] = Role.find(roleid).cache[:credentials]
    #@settings = SystemSettings.find(:first)
    #AuthController.set_current_role(roleid,@request.session)
    #@request.session[:user] = User.find_by_name("suadmin")
    @testUser = users(:ta1).id
    @testAssignment = assignments(:assignment_project1).id
    @testCourse = courses(:course1).id
    @testTeams = teams(:project1_team1).id
  end

  test "view student team" do
    sessionVars = session_for(users(:student1))
    get(:view, {'id' =>  participants(:par1).id}, sessionVars, nil)
    assert_not_nil assigns(:student)
    assert_not_nil assigns(:send_invs)
    assert_not_nil assigns(:received_invs)
  end

  test "edit team" do
    sessionVars = session_for(users(:student8))
    get(:edit,
        {'student_id' => participants(:par21).id, 'team_id' => teams(:IntelligentTeam1).id},
        sessionVars,
        nil)
    assert_not_nil assigns(:student)
    assert_not_nil assigns(:team)
  end

  test "create_student team with valid name " do
    sessionVars = session_for(users(:student1))
    post(:create,
         {'team' => { 'name' => 'test_team'}, 'id' => participants(:par1).id, "commit" => "Create Team"},
         sessionVars,
         nil)
    #something like <"Team \"test_team\" has been created successfully. <a href = http://test.host/versions/revert/12?redo=true>undo</a>
    #assert_equal 'Team "test_team" has been created successfully. ', flash[:notice]
    assert_redirected_to :controller => 'student_team', :action => 'view', :id => participants(:par1).id
    #assert_response :redirect
  end

  test "create_student team with invalid name " do
    sessionVars = session_for(users(:student8))
    post(:create,
         {'team' => { 'name' => 'IntelligentTeam2'}, 'id' => participants(:par21).id, "commit" => "Create Team"},
         sessionVars,
         nil)

    assert_equal 'Team name is already in use.', flash[:notice]

  end

  #this is NOT working... should enable assert_equal
  test "update valid team name" do
    sessionVars = session_for(users(:student8))
    get(:update,
        { 'team' => { 'name' => 'new_name'}, 'student_id' => participants(:par21).id, 'team_id' => teams(:IntelligentTeam1).id},
        sessionVars,
        nil)
    #assert_not_nil assigns(:student)
    #assert_not_nil assigns(:team)
    #assert_equal 'new_name', teams(:IntelligentTeam1).name
  end

  test "update invalid team name" do
    sessionVars = session_for(users(:student8))
    get(:update,
        { 'team' => { 'name' => 'IntelligentTeam2'}, 'student_id' => participants(:par21).id, 'team_id' => teams(:IntelligentTeam1).id},
        sessionVars,
        nil)
    assert_equal 'Team name is already in use.', flash[:notice]
    assert_equal 'IntelligentTeam1', Team.find(teams(:IntelligentTeam1).id).name
  end

  test "update with current team name" do
    sessionVars = session_for(users(:student8))
    get(:update,
        { 'team' => { 'name' => 'IntelligentTeam1'}, 'student_id' => participants(:par21).id, 'team_id' => teams(:IntelligentTeam1).id},
        sessionVars,
        nil)
    #nothing really happens
    assert_redirected_to :controller => 'student_team', :action => 'view', :id => participants(:par21).id
    assert_equal 'IntelligentTeam1', Team.find(teams(:IntelligentTeam1).id).name
  end

=begin
  test "advertise for partners" do
    sessionVars = session_for(users(:student8))
    get(:advertise_for_partners,
        {'team_id' => teams(:IntelligentTeam1).id},
        sessionVars,
        nil)
    team = Team.find_by_name 'IntelligentTeam1'
    assert_true team.advertise_for_partner

  end
=end
  test "remove advertise for partners" do
    sessionVars = session_for(users(:student8))
    get(:remove,
        {'team_id' => teams(:IntelligentTeam1).id},
        sessionVars,
        nil)
    team = Team.find_by_name 'IntelligentTeam1'
    assert_false team.advertise_for_partner

  end

=begin
  #this should fail
  test "leave student team" do
    sessionVars = session_for(users(:student8))
    get(:leave,
        {'student_id' => participants(:par21).id, 'team_id' => teams(:IntelligentTeam1).id},
        sessionVars,
        nil)
    assert_redirected_to :controller => 'student_team', :action => 'view', :id => participants(:par21).id
  end
=end


end

